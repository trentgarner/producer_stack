require "test_helper"

class BeatTest < ActiveSupport::TestCase
  setup do
    @user = users(:basic)
  end

  test "file helper methods return nil when no uploads available" do
    beat = Beat.new(title: "Test Beat", artist: "Tester", user: @user)

    assert_nil beat.beat_file_url
    assert_nil beat.beat_file_content_type
  end

  test "cover art helper methods return nil when nothing attached" do
    beat = Beat.new(title: "Test Beat", artist: "Tester", user: @user)

    assert_nil beat.cover_art_url
    assert_nil beat.cover_art_content_type
  end
end
