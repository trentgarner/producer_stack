class AnalyzeController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def upload
    audio_file = params[:audio_file]

    if audio_file
      # Upload the file to a public URL (e.g., using S3) - This part may need a helper or service
      public_url = upload_to_s3(audio_file) # Replace with actual S3 upload code

      if public_url
        access_token = fetch_access_token
        puts "Access Token: #{access_token}"

        if access_token
          uri = URI("https://api.dolby.com/media/analyze")
          request = Net::HTTP::Post.new(uri)
          request["Authorization"] = "Bearer #{access_token}"
          request["Content-Type"] = "application/json"
          request.body = { url: public_url }.to_json

          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          puts "Response Code: #{response.code}"
          puts "Response Body: #{response.body}"

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
        render json: { error: "File upload failed" }, status: :unprocessable_entity
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
      puts "Error fetching access token: #{response.body}"
      nil
    end
  end

  # Implement the actual S3 upload logic here or in a separate service class
  def upload_to_s3(audio_file)
    # S3 upload code should go here; return the public URL of the file
  end
end
