# frozen_string_literal: true

require 'open3'
require 'fileutils'

module Mastering
  class SoxMasteringService
    Result = Struct.new(:output_path, :public_url, :command, :details, keyword_init: true)

    class MissingDependencyError < StandardError; end
    class ProcessingError < StandardError; end

    PRESET_CHAINS = {
      standard: :standard_chain,
      warm: :warm_chain,
      wide: :wide_chain,
      punchy: :punchy_chain,
      lofi: :lofi_chain,
      clean: :clean_chain
    }.freeze

    PRESET_LABELS = {
      standard: 'Standard Balance',
      warm: 'Warm & Smooth',
      wide: 'Wide & Airy',
      punchy: 'Punchy & Loud',
      lofi: 'Lo-Fi Vibes',
      clean: 'Clean & Clear'
    }.freeze

    MASTERED_DIR = Rails.root.join('public', 'mastered')

    def initialize(temp_dir: Dir.tmpdir)
      @temp_dir = temp_dir
    end

    def process(input_path, original_filename:, preset: :standard)
      ensure_dependencies!

      sanitized_name = sanitize_filename(original_filename.presence || default_filename)
      output_path = build_output_path(sanitized_name)

      command = build_command(input_path, output_path, preset)

      stdout, stderr, status = Open3.capture3(*command)
      unless status.success? && File.exist?(output_path)
        raise ProcessingError, (stderr.presence || stdout.presence || 'Audio mastering failed. Please try again.')
      end

      details = gather_details(output_path)

      Result.new(
        output_path: output_path,
        public_url: public_url_for(output_path),
        command: command.join(' '),
        details: details
      )
    end

    private

    def ensure_dependencies!
      raise MissingDependencyError, 'SoX is required but not available on this system.' unless command_available?('sox')
    end

    def build_command(input_path, output_path, preset)
      FileUtils.mkdir_p(MASTERED_DIR)

      chain_method = PRESET_CHAINS[preset] || PRESET_CHAINS[:standard]
      base_command(input_path, output_path) + send(chain_method)
    end

    def base_command(input_path, output_path)
      ['sox', '--guard', input_path, '-b', '16', output_path]
    end

    def standard_chain
      [
        'compand', '0.3,1', '6:-70,-60,-20', '-5', '-90', '0',
        'equalizer', '80', '0.7q', '3',
        'equalizer', '3200', '1.0q', '2',
        'equalizer', '12000', '0.7q', '-2',
        'bass', '+2',
        'treble', '-1',
        'reverb', '15', '50', '30',
        'gain', '-n', '-1'
      ]
    end

    def warm_chain
      [
        'compand', '0.25,1', '6:-65,-55,-20', '-6', '-90', '0',
        'equalizer', '150', '0.7q', '4',
        'equalizer', '8000', '0.7q', '-3',
        'bass', '+3',
        'treble', '-2',
        'gain', '-n', '-1.5'
      ]
    end

    def wide_chain
      [
        'compand', '0.35,1', '6:-70,-55,-18', '-4', '-90', '0',
        'equalizer', '100', '0.7q', '2',
        'equalizer', '5000', '1.0q', '3',
        'equalizer', '14000', '0.7q', '2',
        'chorus', '0.7', '0.9', '55', '0.4', '0.25', '2', '-t',
        'gain', '-n', '-1'
      ]
    end

    def punchy_chain
      [
        'compand', '0.25,1', '6:-68,-55,-15', '-3', '-90', '0',
        'equalizer', '120', '0.7q', '4',
        'equalizer', '2500', '1.0q', '3',
        'equalizer', '9000', '0.7q', '2',
        'bass', '+2',
        'treble', '+3',
        'gain', '-n', '-0.5'
      ]
    end

    def lofi_chain
      [
        'lowpass', '5000',
        'highpass', '120',
        'compand', '0.3,1', '6:-80,-70,-25', '-8', '-90', '0',
        'contrast', '60',
        'overdrive', '20', '15',
        'tremolo', '6', '40',
        'gain', '-n', '-3'
      ]
    end

    def clean_chain
      [
        'compand', '0.4,1', '6:-80,-70,-25', '-4', '-90', '0',
        'equalizer', '100', '0.7q', '1.5',
        'equalizer', '6000', '0.7q', '1',
        'dither', '-s',
        'gain', '-n', '-1'
      ]
    end

    def gather_details(output_path)
      return {} unless command_available?('sox')

      peak_output, _, peak_status = Open3.capture3('sox', output_path, '-n', 'stat')
      return {} unless peak_status.success?

      peak = peak_output.lines.find { |line| line.include?('Maximum amplitude') }
      rms = peak_output.lines.find { |line| line.include?('RMS     amplitude') }

      {
        peak: extract_stat_value(peak),
        rms: extract_stat_value(rms)
      }.compact
    rescue StandardError
      {}
    end

    def extract_stat_value(line)
      return unless line

      numeric = line.split(':').last.to_s.strip
      Float(numeric)
    rescue ArgumentError
      nil
    end

    def public_url_for(output_path)
      "/mastered/#{File.basename(output_path)}"
    end

    def sanitize_filename(filename)
      base = File.basename(filename, File.extname(filename)).parameterize(separator: '_')
      base.presence || default_filename
    end

    def build_output_path(filename)
      timestamp = Time.current.strftime('%Y%m%d%H%M%S')
      File.join(MASTERED_DIR, "#{timestamp}_#{filename}.wav")
    end

    def command_available?(command)
      ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |path|
        File.executable?(File.join(path, command))
      end
    end

    def default_filename
      'mastered_track'
    end
  end
end
