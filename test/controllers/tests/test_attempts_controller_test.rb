require "test_helper"

class Tests::TestAttemptsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @test = tests(:one)
    @user = users(:student)
    @admin = users(:admin)
    @attempt = test_attempts(:one)
  end

  test "should redirect to login when not signed in" do
    get tests_test_attempts_url
    assert_redirected_to new_user_session_path
  end

  test "should get new test attempt for enrolled user" do
    sign_in @user
    # Create payment to make user enrolled
    Payment.create!(user: @user, payable: @test.course, status: 'succeeded', amount: @test.course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_attempt_test_654')
    
    get new_tests_test_attempt_url(test_id: @test.id)
    # Since the test requires honor statement, should redirect to honor statement page
    assert_redirected_to honor_statement_test_path(@test)
  end

  test "should redirect non-enrolled user from new test attempt" do
    sign_in @user
    # User has no payment for this course
    
    get new_tests_test_attempt_url(test_id: @test.id)
    # Since the test requires honor statement, should redirect to honor statement page
    assert_redirected_to honor_statement_test_path(@test)
  end

  test "should create test attempt for enrolled user" do
    sign_in @user
    # Create payment to make user enrolled
    Payment.create!(user: @user, payable: @test.course, status: 'succeeded', amount: @test.course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_attempt_test_654')
    
    assert_difference('TestAttempt.count') do
      post tests_test_attempts_url, params: {
        test_id: @test.id,
        honor_statement: '1'
      }
    end

    attempt = TestAttempt.last
    assert_equal @user, attempt.user
    assert_equal @test, attempt.test
    assert_not attempt.submitted?
  end

  test "should not create test attempt for non-enrolled user" do
    sign_in @user
    # User has no payment for this course
    
    assert_no_difference('TestAttempt.count') do
      post tests_test_attempts_url, params: {
        test_id: @test.id,
        honor_statement: '1'
      }
    end

    assert_redirected_to course_url(@test.course)
    assert_equal "You must be enrolled in this course to take its tests.", flash[:alert]
  end

  test "should get edit for own test attempt" do
    sign_in @user
    # Create a non-submitted test attempt for editing
    non_submitted_attempt = TestAttempt.create!(
      user: @user,
      test: @test,
      submitted: false,
      honor_statement_accepted: true,
      retake_number: 1,
      start_time: Time.current,
      end_time: nil
    )
    get edit_tests_test_attempt_url(non_submitted_attempt)
    assert_response :success
  end

  test "should update own test attempt" do
    sign_in @user
    patch tests_test_attempt_url(@attempt), params: {
      test_attempt: {
        submitted: true,
        score: 85
      }
    }
    assert_redirected_to tests_test_attempt_url(@attempt)
    @attempt.reload
    assert @attempt.submitted?
    assert_equal 85, @attempt.score
  end

  test "should get show for own test attempt" do
    sign_in @user
    get tests_test_attempt_url(@attempt)
    assert_response :success
  end

  test "should not update another user's test attempt" do
    other_user = users(:admin)
    sign_in other_user
    
    patch tests_test_attempt_url(@attempt), params: {
      test_attempt: {
        submitted: true,
        score: 100
      }
    }
    
    assert_redirected_to tests_test_attempts_path
    assert_equal "Test attempt not found.", flash[:alert]
  end

  test "should allow admin to access all test attempts" do
    sign_in @admin
    get tests_test_attempts_url
    assert_response :success
  end
end