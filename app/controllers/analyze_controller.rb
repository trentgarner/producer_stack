
class AnalyzeController < ApplicationController
require 'net/http'
require 'uri'
require 'json'
  # before_action :set_beat, only: [:show, :edit, :update, :destroy]
  # before_action :validate_user, only: [:edit, :update, :destroy]
  # before_action :authenticate_user!, except: [:index, :show]

  def upload
    audio_file = params[:audio_file]
    
    # Create a file object to pass to the API
    file_path = audio_file.path
    
    # Call Dolby API
    uri = URI("https://api.dolby.io/v1/analyze")
    request = Net::HTTP::Post.new(uri)
    "Authorization" => "Bearer #{ENV['DOLBY_API_KEY']}"
    request.set_form([["file", File.open(file_path)]], "multipart/form-data")

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse the response
    if response.is_a?(Net::HTTPSuccess)
      @analysis_results = JSON.parse(response.body)
      render json: @analysis_results
    else
      render json: { error: "Analysis failed" }, status: :unprocessable_entity
    end
    def index
      # This action will render the upload page view
    end
  
    def upload
      # Your existing upload code here
    end
  end

  
end
