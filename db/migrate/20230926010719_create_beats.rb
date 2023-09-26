class CreateBeats < ActiveRecord::Migration[7.0]
  def change
    create_table :beats do |t|
      t.binary :beat 
      t.string :title, null: false
      t.string :artist, null: false
      t.string :genre
      t.text :description
      t.decimal :duration, precision: 6, scale: 2
      t.datetime :upload_date
      t.decimal :price, precision: 10, scale: 2
      t.string :license_type
      t.integer :sample_rate
      t.integer :bit_depth
      t.text :tags
      t.integer :downloads_count, default: 0
      t.integer :plays_count, default: 0
      t.decimal :rating, precision: 10
      t.binary :cover_art
      t.string :cover_art_url
      t.string :beat_file_name
      t.string :beat_content_type
      t.integer :beat_file_size
      t.timestamps
    end
  end
end
