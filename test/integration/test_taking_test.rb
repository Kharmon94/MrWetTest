require "test_helper"

class TestTakingTest < ActionDispatch::IntegrationTest
  def setup
    @course = courses(:one)
    @test = tests(:one)
    @user = users(:student)
    @admin = users(:admin)
  end

  test "enrolled user should access test from course" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    # Start from course page
    get course_path(@course)
    assert_response :success

    # Navigate to course tests
    get course_tests_path(@course)
    assert_response :success

    # Access specific test
    get course_test_path(@course, @test)
    assert_response :success
    assert_select "h1", text: @test.title
  end

  test "user should see honor statement for tests requiring it" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    @test.update!(honor_statement_required: true)

    # Try to start test
    get new_tests_test_attempt_path(test_id: @test.id)
    
    if @test.requires_honor_statement?
      # Should redirect to honor statement
      assert_redirected_to honor_statement_test_path(@test)
    else
      # Should allow starting test directly
      assert_response :success
    end
  end

  test "user should accept honor statement and start test" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    @test.update!(honor_statement_required: true)

    # Get honor statement page
    get honor_statement_test_path(@test)
    assert_response :success

    # Accept honor statement
    post accept_honor_test_path(@test)
    assert_redirected_to new_tests_test_attempt_path(test_id: @test.id)

    # Should now be able to start test
    get new_tests_test_attempt_path(test_id: @test.id)
    assert_response :success
  end

  test "user should create and take test attempt" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    # Create test attempt
    assert_difference('TestAttempt.count') do
      post tests_test_attempts_path, params: {
        test_attempt: {
          test_id: @test.id,
          user_id: @user.id
        }
      }
    end

    attempt = TestAttempt.last
    assert_equal @user, attempt.user
    assert_equal @test, attempt.test
    assert_not attempt.submitted?

    # Edit test attempt (taking the test)
    get edit_tests_test_attempt_path(attempt)
    assert_response :success

    # Submit test attempt
    patch tests_test_attempt_path(attempt), params: {
      test_attempt: {
        submitted: true,
        score: 85
      }
    }
    assert_redirected_to tests_test_attempt_path(attempt)

    attempt.reload
    assert attempt.submitted?
    assert_equal 85, attempt.score
  end

  test "user should not be able to retake test after max attempts" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
      @test.update!(max_attempts: 1)

      # Create first attempt
      post tests_test_attempts_path, params: {
        test_attempt: {
          test_id: @test.id,
          user_id: @user.id
        }
      }

      attempt = TestAttempt.last
      attempt.update!(submitted: true, score: 60) # Failing score

      # Try to create another attempt
      assert_no_difference('TestAttempt.count') do
        post tests_test_attempts_path, params: {
          test_attempt: {
            test_id: @test.id,
            user_id: @user.id
          }
        }
      end

    # Should be redirected with error message
    assert_redirected_to course_test_path(@course, @test)
    assert_equal "You have reached the maximum number of attempts for this test.", flash[:alert]
  end

  test "user should be able to retake test within max attempts" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
      @test.update!(max_attempts: 3)

      # Create first attempt
      post tests_test_attempts_path, params: {
        test_attempt: {
          test_id: @test.id,
          user_id: @user.id
        }
      }

      attempt1 = TestAttempt.last
      attempt1.update!(submitted: true, score: 60) # Failing score

    # Should be able to create second attempt
    assert_difference('TestAttempt.count') do
      post tests_test_attempts_path, params: {
        test_attempt: {
          test_id: @test.id,
          user_id: @user.id
        }
      }
    end
  end

  test "user should abandon assessment and not submit" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
      # Create test attempt
      post tests_test_attempts_path, params: {
        test_attempt: {
          test_id: @test.id,
          user_id: @user.id
        }
      }

      attempt = TestAttempt.last

      # Abandon assessment
      post abandon_tests_test_attempt_path(attempt)
      assert_redirected_to tests_test_attempt_path(attempt)

    attempt.reload
    assert attempt.abandoned?
    assert_not attempt.submitted?
  end

  test "user should view their test attempt history" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    # Create completed attempt
    attempt = TestAttempt.create!(
      user: @user,
      test: @test,
      submitted: true,
      score: 85,
      honor_statement_accepted: true,
      retake_number: 1,
      start_time: Time.current,
      end_time: Time.current
    )

    get tests_test_attempts_path
    assert_response :success
    assert_select "table" # Should show attempts table
    assert_select "td", text: @test.title
  end

  test "admin should access all test attempts" do
    sign_in @admin

    # Create attempt for student
    attempt = TestAttempt.create!(
      user: @user,
      test: @test,
      submitted: true,
      score: 75,
      honor_statement_accepted: true,
      retake_number: 1,
      start_time: Time.current,
      end_time: Time.current
    )

    # Admin should be able to view any attempt
    get tests_test_attempt_path(attempt)
    assert_response :success

    get edit_tests_test_attempt_path(attempt)
    assert_response :success
  end

  test "user should not access another user's test attempts" do
    other_user = users(:admin)
    sign_in other_user

    # Create attempt for different user
    attempt = TestAttempt.create!(
      user: @user,
      test: @test,
      submitted: true,
      score: 75,
      honor_statement_accepted: true,
      retake_number: 1,
      start_time: Time.current,
      end_time: Time.current
    )

    # Should not be able to view other user's attempt
    get tests_test_attempt_path(attempt)
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should not modify submitted test attempts" do
    sign_in @user
    # Create a payment to make user enrolled
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_integration_test_789')
    
    # Create and submit attempt
    attempt = TestAttempt.create!(
      user: @user,
      test: @test,
      submitted: true,
      score: 85,
      honor_statement_accepted: true,
      retake_number: 1,
      start_time: Time.current,
      end_time: Time.current
    )

    original_score = attempt.score

    # Try to modify submitted attempt
    patch tests_test_attempt_path(attempt), params: {
      test_attempt: {
        score: 100
      }
    }

    attempt.reload
    assert_equal original_score, attempt.score
  end
end
