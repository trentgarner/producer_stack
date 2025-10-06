if Rails.env.production? || Rails.env.development?
  ENV['LD_LIBRARY_PATH'] = "/opt/homebrew/Cellar/aubio/0.4.9/lib"
end