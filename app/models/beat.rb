class Beat < ApplicationRecord
  include Rails.application.routes.url_helpers

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
    return unless beat.present?

    beat.url
  end

  def beat_file_content_type
    return unless beat.present?

    beat.content_type
  end

  def cover_art_url
    return unless cover_art.attached?

    rails_blob_path(cover_art, only_path: true)
  end

  def cover_art_content_type
    return unless cover_art.attached?

    cover_art.blob.content_type
  end
end
