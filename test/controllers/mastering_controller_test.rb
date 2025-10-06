require "test_helper"

class MasteringControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:basic)
    sign_in @user
  end

  test "shows mastering page" do
    get mastering_index_url
    assert_response :success
  end

  test "returns to page when no file provided" do
    post upload_mastering_index_url
    assert_redirected_to mastering_index_url
    assert_equal 'No audio file uploaded.', flash[:error]
  end

  test "renders result when mastering succeeds" do
    result = Mastering::SoxMasteringService::Result.new(
      output_path: Rails.root.join('public', 'mastered', 'test.wav').to_s,
      public_url: '/mastered/test.wav',
      command: 'sox input output',
      details: { peak: 0.8 }
    )

    file = Tempfile.new(['fixture', '.wav'])
    file.write('audio')
    file.rewind

    uploaded_file = Rack::Test::UploadedFile.new(file.path, 'audio/wav', original_filename: 'fixture.wav')

    fake_service_class = Class.new do
      class << self
        attr_accessor :result
      end

      def process(_path, original_filename:, preset:)
        raise ArgumentError unless original_filename.present? && preset.present?
        self.class.result
      end
    end

    fake_service_class.result = result

    original_method = MasteringController.instance_method(:mastering_service_class)
    MasteringController.define_method(:mastering_service_class) { fake_service_class }

    post upload_mastering_index_url, params: { audio_file: uploaded_file, preset: 'wide' }

    assert_response :success
    assert_select 'a[href="/mastered/test.wav"]', text: 'Download Mastered Track'
  ensure
    file.close!
    MasteringController.define_method(:mastering_service_class, original_method)
  end
end
