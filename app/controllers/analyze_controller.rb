class AnalyzeController < ApplicationController
  def index
    @analysis_data = nil
  end

  def upload
    uploaded_file = params[:audio_file]

    if uploaded_file
      file_path = save_audio_file(uploaded_file)

      # Perform analysis using aubio
      @analysis_data = analyze_audio(file_path)

      if @analysis_data
        render :index
      else
        flash[:error] = "There was an error analyzing the audio."
        render :index
      end
    else
      flash[:error] = "No file uploaded"
      render :index
    end
  end

  private

  def save_audio_file(file)
    # Ensure the uploads directory exists
    uploads_dir = Rails.root.join('public', 'uploads')
    FileUtils.mkdir_p(uploads_dir) unless File.exist?(uploads_dir)

    # Save the uploaded file to disk
    file_path = uploads_dir.join(file.original_filename)
    File.open(file_path, 'wb') do |f|
      f.write(file.read)
    end
    file_path
  end

  def analyze_audio(file_path)
    require 'aubio'
  
    begin
      # Convert file_path to a string before passing it to Aubio
      my_file = Aubio.open(file_path.to_s)
  
      # Extract BPM (beats per minute)
      bpm_data = my_file.beats.to_a
      bpm = bpm_data.map { |beat| beat[:s] }
  
      # Ensure bpm is a float if available, otherwise default to 0.0
      bpm = bpm.first.to_f if bpm.any?
  
      # Extract Key (using pitches as an example)
      key = my_file.pitches.to_a.first || "Unknown"
  
      # Example: Use the first beat or set to "Unknown" if not available
      time_signature = bpm != 0.0 ? bpm : "Unknown"
  
      # Calculate the duration of the audio file
      duration = File.size(file_path).to_f / (44100 * 2 * 2) # 44.1kHz sample rate, 16-bit stereo
  
      {
        bpm: bpm,
        key: key,
        time_signature: time_signature,
        duration: duration
      }
  
    rescue => e
      Rails.logger.error("Error analyzing audio: #{e.message}")
      nil
    end
  end  
  
end
