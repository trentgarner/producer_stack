class Beat < ApplicationRecord
  mount_uploader :beat, BeatUploader
  has_one_attached :cover_art
  belongs_to :user

  validates :title, presence: true
  validates :artist, presence: true
  validates :duration, numericality: { greater_than: 0 }, allow_nil: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :sample_rate, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :bit_depth, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def beat_file_url
    beat.url # Use .url to get the URL
  end

  def beat_file_content_type
    beat.content_type
  end

  def cover_art_url
    cover_art.url # Use .url to get the URL
  end

  def cover_art_content_type
    cover_art.content_type
  end
end
