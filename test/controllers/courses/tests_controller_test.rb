require "test_helper"

class Courses::TestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @course = courses(:one)
    @test = tests(:one)
    @user = users(:student)
    @admin = users(:admin)
  end

  test "should get index for course tests" do
    sign_in @user
    # Create payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_course_test_321')
    
    get course_tests_url(@course)
    assert_response :success
    assert_select "h1", text: /tests/i
  end

  test "should redirect non-enrolled users from course tests index" do
    sign_in @user
    # User has no payment for this course
    
    get course_tests_url(@course)
    assert_redirected_to course_url(@course)
    assert_equal "You must be enrolled in this course to access its tests.", flash[:alert]
  end

  test "should allow admin to access course tests index" do
    sign_in @admin
    get course_tests_url(@course)
    assert_response :success
  end

  test "should get show for specific course test" do
    sign_in @user
    # Create payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_course_test_321')
    
    get course_test_url(@course, @test)
    assert_response :success
    assert_select "h1", text: @test.title
  end

  test "should redirect non-enrolled users from specific course test" do
    sign_in @user
    # User has no payment for this course
    
    get course_test_url(@course, @test)
    assert_redirected_to course_url(@course)
    assert_equal "You must be enrolled in this course to access its tests.", flash[:alert]
  end

  test "should allow admin to access specific course test" do
    sign_in @admin
    get course_test_url(@course, @test)
    assert_response :success
  end

  test "should redirect to course for invalid test" do
    sign_in @user
    # Create payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_course_test_321')
    
    get course_test_url(@course, 99999)
    assert_redirected_to course_url(@course)
    assert_equal "Test not found.", flash[:alert]
  end

  test "should redirect to login when not signed in" do
    get course_tests_url(@course)
    assert_redirected_to new_user_session_path
  end

  test "should only show tests belonging to the course" do
    sign_in @admin
    get course_tests_url(@course)
    assert_response :success
    
    # Should only show tests that belong to this course
    @course.tests.each do |test|
      assert_select "a[href=?]", course_test_path(@course, test)
    end
  end
end