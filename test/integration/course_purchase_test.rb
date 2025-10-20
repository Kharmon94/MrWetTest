require "test_helper"

class CoursePurchaseTest < ActionDispatch::IntegrationTest
  def setup
    @course = courses(:one)
    @user = users(:student)
    @admin = users(:admin)
    
    # Assign roles to users
    @user.add_role(:student) unless @user.has_role?(:student)
    @admin.add_role(:admin) unless @admin.has_role?(:admin)
  end

  test "guest should browse courses without purchasing" do
    get courses_path
    assert_response :success
    assert_select "h1", text: /courses/i

    get course_path(@course)
    assert_response :success
    assert_select "h1", text: @course.title

    # Should see course details but not tests section
    assert_select "h3", text: /tests/i, count: 0
  end

  test "user should purchase course and access tests" do
    sign_in @user

    # Create payment directly
    payment = Payment.create!(
      user: @user,
      payable: @course,
      amount: @course.price,
      currency: 'usd',
      status: 'succeeded',
      stripe_payment_intent_id: 'pi_course_purchase_123'
    )

    # Should now be able to access course tests
    get course_path(@course)
    assert_response :success
    assert_select "h3", text: /tests/i

    get course_tests_path(@course)
    assert_response :success
  end

  test "user should not access tests before purchasing course" do
    sign_in @user

    get course_path(@course)
    assert_response :success
    # Should not see tests section for non-purchased course
    assert_select "h3", text: /tests/i, count: 0

    # Should be redirected when trying to access tests directly
    get course_tests_path(@course)
    assert_redirected_to course_path(@course)
    assert_equal "You must be enrolled in this course to access its tests.", flash[:alert]
  end

  test "admin should access all courses and tests without purchasing" do
    sign_in @admin

    get course_path(@course)
    assert_response :success
    # Admin should see tests section
    assert_select "h3", text: /tests/i

    get course_tests_path(@course)
    assert_response :success
  end

  test "should show purchase button for non-enrolled users" do
    sign_in @user

    get course_path(@course)
    assert_response :success
    
    # Should show purchase/enroll button
    assert_select "a[href*='payments/new']", text: /purchase/i
  end

  test "should not show purchase button for enrolled users" do
    sign_in @user

    # Create payment to make user enrolled
    Payment.create!(
      user: @user,
      payable: @course,
      amount: @course.price,
      currency: 'usd',
      status: 'succeeded',
      stripe_payment_intent_id: 'pi_course_purchase_123'
    )

    get course_path(@course)
    assert_response :success
    
    # Should not show purchase button
    assert_select "a[href=?]", new_payment_path, count: 0
  end

  test "should not show purchase button for free courses" do
    @course.update!(price: 0)
    sign_in @user

    get course_path(@course)
    assert_response :success
    
    # Should not show purchase button for free courses
    assert_select "a[href=?]", new_payment_path, count: 0
    
    # Should be able to access tests directly
    get course_tests_path(@course)
    assert_response :success
  end

  test "should handle payment failure gracefully" do
    sign_in @user

    # Create a failed payment
    Payment.create!(
      user: @user,
      payable: @course,
      amount: @course.price,
      currency: 'usd',
      status: 'failed',
      stripe_payment_intent_id: 'pi_test_failed'
    )

    # Should still not have access to tests
    get course_tests_path(@course)
    assert_redirected_to course_path(@course)
  end

  test "should show payment history for enrolled users" do
    sign_in @user

    # Create a successful payment
    payment = Payment.create!(
      user: @user,
      payable: @course,
      amount: @course.price,
      currency: 'usd',
      status: 'succeeded',
      stripe_payment_intent_id: 'pi_course_purchase_123'
    )

    get payments_path
    assert_response :success
    assert_select "table" # Should show payments table
    assert_select "h6", text: @course.title
  end

  test "should show empty state for users with no payments" do
    # Create a new user with no payments
    new_user = User.create!(
      email: "newuser@test.com",
      password: "password123",
      theme_preference: "light",
      email_notifications: true,
      push_notifications: false,
      language: "en"
    )
    new_user.add_role(:student)
    
    sign_in new_user

    get payments_path
    assert_response :success
    assert_select "h4", text: /no payments yet/i
  end
end
