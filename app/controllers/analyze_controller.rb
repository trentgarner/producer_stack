class AnalyzeController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    # This action will render the upload page view
  end

  def upload
    audio_file = params[:audio_file]

    if audio_file
      file_path = audio_file.path

      # Fetch access token before making the analysis request
      access_token = fetch_access_token

      if access_token
        uri = URI("https://api.dolby.io/v1/analyze")
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{access_token}"
        request.set_form([["file", File.open(file_path)]], "multipart/form-data")

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          @analysis_results = JSON.parse(response.body)
          render json: @analysis_results
        else
          render json: { error: "Analysis failed: #{response.message}" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Failed to fetch access token" }, status: :unauthorized
      end
    else
      render json: { error: "No audio file uploaded" }, status: :unprocessable_entity
    end
  end

  private

  def fetch_access_token
    uri = URI("https://api.dolby.io/v1/auth/token")
    request = Net::HTTP::Post.new(uri)
    request.set_form([["grant_type", "client_credentials"], ["expires_in", 1800]], "application/x-www-form-urlencoded")
    request.basic_auth(ENV['DOLBY_API_KEY'], ENV['DOLBY_API_SECRET'])

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)["access_token"]
    else
      nil # Handle error appropriately
    end
  end
end
