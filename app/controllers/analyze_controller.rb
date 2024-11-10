# app/controllers/analyze_controller.rb

require 'open3'

class AnalyzeController < ApplicationController
  def index
    # Display the upload form and any previously analyzed data
  end

  def upload
    if params[:audio_file].present?
      # Save the uploaded file to a local path
      file = params[:audio_file]
      file_path = Rails.root.join('public', 'uploads', file.original_filename)
      File.open(file_path, 'wb') { |f| f.write(file.read) }

      # Call the analyze_audio method to get audio analysis data
      @analysis_data = analyze_audio(file_path.to_s)

      if @analysis_data
        render :index
      else
        flash[:error] = "Audio analysis failed. Please try again."
        redirect_to analyze_index_path
      end
    else
      flash[:error] = "No audio file provided."
      redirect_to analyze_index_path
    end
  end

  private

  def analyze_audio(file_path)
    analysis = { bpm: "Unavailable", key: "Unavailable", duration: "Unknown" }

    begin
      # Analyze tempo (BPM) using Aubio CLI
      bpm_command = "aubio tempo '#{file_path}'"
      bpm_output, bpm_error = Open3.capture3(bpm_command)
      if bpm_error.empty? && bpm_output.present?
        bpm = bpm_output.match(/(\d+\.\d+)/)[1]
        analysis[:bpm] = bpm || "Unavailable"
      else
        Rails.logger.error("Aubio tempo error: #{bpm_error}")
      end

      # Analyze key using Aubio CLI
      key_command = "aubio pitch '#{file_path}'"
      key_output, key_error = Open3.capture3(key_command)
      if key_error.empty? && key_output.present?
        key = key_output.match(/(\w+)/)[1]
        analysis[:key] = key || "Unavailable"
      else
        Rails.logger.error("Aubio pitch error: #{key_error}")
      end

      # Additional optional analysis (duration) - example
      duration_command = "ffmpeg -i '#{file_path}' 2>&1 | grep Duration"
      duration_output, _ = Open3.capture2(duration_command)
      duration_match = duration_output.match(/Duration: (\d+:\d+:\d+\.\d+)/)
      analysis[:duration] = duration_match[1] if duration_match

      analysis
    rescue => e
      Rails.logger.error("Error analyzing audio: #{e.message}")
      nil
    end
  end
end
