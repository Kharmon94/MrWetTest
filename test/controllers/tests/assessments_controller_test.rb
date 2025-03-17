require "test_helper"

class Tests::AssessmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get tests_assessments_new_url
    assert_response :success
  end

  test "should get show" do
    get tests_assessments_show_url
    assert_response :success
  end
end
