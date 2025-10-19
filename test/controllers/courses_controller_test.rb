require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @course = courses(:one)
    @user = users(:student)
    @admin = users(:admin)
  end

  test "should get index" do
    get courses_url
    assert_response :success
    assert_select "h1", text: /courses/i
  end

  test "should get show for valid course" do
    get course_url(@course)
    assert_response :success
    assert_select "h1", text: @course.title
  end

  test "should redirect to root for invalid course" do
    get course_url(99999)
    assert_redirected_to root_path
    assert_equal "Course not found.", flash[:alert]
  end

  test "should show tests for enrolled users" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price, 
                   currency: 'usd', stripe_payment_intent_id: 'pi_courses_controller_456')
    
    get course_url(@course)
    assert_response :success
    # Should show tests section
    assert_select "h3", text: /tests/i
  end

  test "should not show tests for non-enrolled users" do
    sign_in @user
    # User has no payment for this course
    
    get course_url(@course)
    assert_response :success
    # Should not show tests section for non-enrolled users
    assert_select "h3", text: /tests/i, count: 0
  end

  test "should show tests for admin users" do
    sign_in @admin
    get course_url(@course)
    assert_response :success
    # Admin should see tests section
    assert_select "h3", text: /tests/i
  end

  test "should get browse page" do
    get browse_courses_url
    assert_response :success
  end

  test "should redirect to login for admin actions when not signed in" do
    get new_course_url
    assert_redirected_to new_user_session_path
  end

  test "should allow admin to access new course page" do
    sign_in @admin
    get new_course_url
    assert_response :success
  end

  test "should not allow students to access new course page" do
    sign_in @user
    get new_course_url
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end
end
