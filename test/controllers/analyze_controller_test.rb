require "test_helper"

class AnalyzeControllerTest < ActionDispatch::IntegrationTest
  test "upload without file responds with error and redirect" do
    sign_in users(:basic)

    post upload_analyze_index_path

    assert_redirected_to analyze_index_path
    assert_equal "No audio file provided.", flash[:error]
  end
end
