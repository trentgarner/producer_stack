class AnalyzeController < ApplicationController
  require 'open3'
  require 'tempfile'
  require 'json'

  def index; end

  def upload
    file = params[:audio_file]
    unless file.present?
      flash[:error] = 'No audio file provided.'
      return redirect_to analyze_index_path
    end

    tempfile = Tempfile.new(['producer_stack_analysis', File.extname(file.original_filename)])
    tempfile.binmode
    tempfile.write(file.read)
    tempfile.flush

    @analysis_data = analyze_audio(tempfile.path)

    if @analysis_data
      render :index
    else
      flash[:error] = 'Audio analysis failed. Please try again.'
      redirect_to analyze_index_path
    end
  ensure
    tempfile.close! if tempfile
  end

  private

  def analyze_audio(file_path)
    begin
      bpm = extract_bpm(file_path)
      key = extract_key(file_path)
      time_signature = extract_time_signature(file_path)

      analysis = {
        bpm: bpm ? bpm.round(2) : 'Unavailable',
        key: key || 'Unavailable',
        duration: 'Unknown',
        time_signature: time_signature || '4/4 (default)'
      }

      duration_seconds = extract_duration(file_path)
      analysis[:duration] = formatted_duration(duration_seconds) if duration_seconds

      analysis
    rescue StandardError => e
      Rails.logger.error("Error analyzing audio: #{e.message}")
      nil
    end
  end

  def formatted_duration(total_seconds)
    return 'Unknown' unless total_seconds.positive?

    Time.at(total_seconds).utc.strftime('%H:%M:%S')
  end

  def extract_bpm(file_path)
    return unless command_available?('aubio')

    output, error, status = Open3.capture3('aubio', 'tempo', file_path)
    if status.success?
      value = output[/\d+(?:\.\d+)?/]
      return value.to_f if value
    end

    Rails.logger.error("Aubio tempo error: #{error.presence || output}")
    nil
  rescue Errno::ENOENT => e
    Rails.logger.error("aubio tempo command missing: #{e.message}")
    nil
  end

  def extract_key(file_path)
    metadata = ffprobe_tags(file_path, %w[initial_key key])
    return normalize_key(metadata[:initial_key] || metadata[:key]) if metadata.present?

    return unless command_available?('aubio')

    key_output, key_error, key_status = Open3.capture3('aubio', 'key', file_path)
    if key_status.success?
      match = key_output.match(/([A-G][#b]?)(?:\s+((?:major|minor)))/i)
      return format_key_match(match) if match
    else
      Rails.logger.error("Aubio key error: #{key_error.presence || key_output}")
    end

    pitch_output, pitch_error, pitch_status = Open3.capture3('aubio', 'pitch', file_path)
    if pitch_status.success?
      frequency = pitch_output.each_line.lazy.map { |line| line.split.last.to_f }.find { |value| value.positive? }
      return frequency_to_note(frequency) if frequency
    else
      Rails.logger.error("Aubio pitch error: #{pitch_error.presence || pitch_output}")
    end

    nil
  rescue Errno::ENOENT => e
    Rails.logger.error("aubio key command missing: #{e.message}")
    nil
  end

  def extract_time_signature(file_path)
    metadata = ffprobe_tags(file_path, %w[time_signature])
    return sanitize_time_signature(metadata[:time_signature]) if metadata[:time_signature].present?

    return unless command_available?('aubio')

    beat_output, beat_error, beat_status = Open3.capture3('aubio', 'tempo', file_path)
    return infer_time_signature_from_beats(beat_output) if beat_status.success?

    Rails.logger.error("Aubio tempo (for signature) error: #{beat_error.presence || beat_output}")
    nil
  rescue Errno::ENOENT => e
    Rails.logger.error("aubio tempo command missing: #{e.message}")
    nil
  end

  def extract_duration(file_path)
    if command_available?('ffprobe')
      output, error, status = Open3.capture3('ffprobe', '-i', file_path, '-show_entries', 'format=duration', '-v', 'quiet', '-of', 'csv=p=0')
      return output.to_f if status.success?

      Rails.logger.error("ffprobe duration error: #{error.presence || output}")
    elsif command_available?('ffmpeg')
      output, status = Open3.capture2('ffmpeg', '-i', file_path, '-hide_banner')
      match = output.match(/Duration: (\d+):(\d+):(\d+\.\d+)/)
      if status.success? && match
        hours, minutes, seconds = match.captures
        return hours.to_i * 3600 + minutes.to_i * 60 + seconds.to_f
      end
    else
      Rails.logger.error('Unable to compute duration: ffprobe/ffmpeg not installed or not found in PATH.')
    end

    nil
  rescue Errno::ENOENT => e
    Rails.logger.error("Duration command missing: #{e.message}")
    nil
  end

  def command_available?(command)
    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |path|
      File.executable?(File.join(path, command))
    end
  end

  def ffprobe_tags(file_path, keys)
    return {} unless command_available?('ffprobe')

    tag_list = keys.join(',')
    output, error, status = Open3.capture3('ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_entries', "format_tags=#{tag_list}", file_path)
    return {} unless status.success?

    data = JSON.parse(output)
    tags = data.fetch('format', {}).fetch('tags', {})
    tags.transform_keys { |k| k.downcase.to_sym }
  rescue JSON::ParserError => e
    Rails.logger.error("ffprobe metadata parse error: #{e.message}")
    {}
  rescue Errno::ENOENT => e
    Rails.logger.error("ffprobe command missing: #{e.message}")
    {}
  end

  def normalize_key(raw_key)
    return if raw_key.blank?

    key = raw_key.to_s.strip
    key.gsub!(/\s+/, ' ')
    key.split.map.with_index do |segment, index|
      index.zero? ? segment.upcase : segment.capitalize
    end.join(' ')
  end

  def format_key_match(match)
    tonic = match[1].upcase
    scale = match[2]&.downcase
    [tonic, scale].compact.join(' ')
  end

  def frequency_to_note(frequency)
    return if frequency.nil? || frequency <= 0.0

    note_names = %w[C C# D D# E F F# G G# A A# B]
    midi_number = (12 * Math.log2(frequency / 440.0) + 69).round
    note = note_names[midi_number % 12]
    octave = (midi_number / 12) - 1
    "#{note}#{octave} (estimated)"
  end

  def sanitize_time_signature(signature)
    sanitized = signature.to_s.strip
    return sanitized if sanitized.match?(/\A\d+\s*\/\s*\d+\z/)

    sanitized
  end

  def infer_time_signature_from_beats(beat_output)
    beats = beat_output.each_line.map { |line| line.to_f }.select { |time| time.positive? }
    return if beats.size < 4

    '4/4 (estimated)'
  end
end
