class CleanupBeatsLegacyColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :beats, :cover_art, :binary
    remove_column :beats, :cover_art_url, :string
    remove_column :beats, :beat_file_name, :string
    remove_column :beats, :beat_content_type, :string
    remove_column :beats, :beat_file_size, :integer
  end
end
