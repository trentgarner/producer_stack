class AnalyzeController < ApplicationController
  require 'open3'
  require 'tempfile'

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
    analysis = { bpm: 'Unavailable', key: 'Unavailable', duration: 'Unknown', time_signature: 'Unavailable' }

    begin
      bpm_output, bpm_error, bpm_status = Open3.capture3('aubio', 'tempo', file_path)
      if bpm_status.success?
        bpm_match = bpm_output.match(/(\d+(?:\.\d+)?)/)
        analysis[:bpm] = bpm_match[1] if bpm_match
      else
        Rails.logger.error("Aubio tempo error: #{bpm_error.presence || bpm_output}")
      end

      key_output, key_error, key_status = Open3.capture3('aubio', 'pitch', file_path)
      if key_status.success?
        key_match = key_output.match(/([A-G](?:#|b)?)/)
        analysis[:key] = key_match[1].upcase if key_match
      else
        Rails.logger.error("Aubio pitch error: #{key_error.presence || key_output}")
      end

      duration_output, duration_error, duration_status = Open3.capture3('ffprobe', '-i', file_path, '-show_entries', 'format=duration', '-v', 'quiet', '-of', 'csv=p=0')
      if duration_status.success?
        analysis[:duration] = formatted_duration(duration_output.to_f)
      else
        Rails.logger.error("ffprobe duration error: #{duration_error.presence || duration_output}")
      end

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
end
