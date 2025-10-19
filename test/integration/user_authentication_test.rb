require "test_helper"

class UserAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:student)
    @admin = users(:admin)
  end

  test "should sign up new user with student role" do
    get new_user_registration_path
    assert_response :success

    assert_difference('User.count') do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          theme_preference: "light",
          email_notifications: true,
          push_notifications: false,
          language: "en"
        }
      }
    end

    new_user = User.last
    assert_equal "newuser@example.com", new_user.email
    assert new_user.has_role?(:student)
    assert_not new_user.has_role?(:admin)
    assert_not new_user.has_role?(:instructor) # Should not exist
  end

  test "should sign in existing user" do
    get new_user_session_path
    assert_response :success

    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }

    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
  end

  test "should sign in admin user" do
    get new_user_session_path
    assert_response :success

    post user_session_path, params: {
      user: {
        email: @admin.email,
        password: "password123"
      }
    }

    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
  end

  test "should sign out user" do
    sign_in @user
    delete destroy_user_session_path
    assert_redirected_to root_path
    assert_equal "Signed out successfully.", flash[:notice]
  end

  test "should redirect to login for protected pages when not signed in" do
    get courses_path
    assert_response :success # Courses index is public

    get tests_test_attempts_path
    assert_redirected_to new_user_session_path # Test attempts require login

    get admin_root_path
    assert_redirected_to new_user_session_path # Admin requires login
  end

  test "should show appropriate navigation for signed in users" do
    sign_in @user
    get root_path
    assert_response :success
    
    # Should show "My Progress" link instead of "Sign Up"
    assert_select "a[href=?]", tests_test_attempts_path, text: /my progress/i
    assert_select "a[href=?]", new_user_registration_path, count: 0
  end

  test "should show sign up link for guest users" do
    get root_path
    assert_response :success
    
    # Should show "Sign Up" link for guests
    assert_select "a[href=?]", new_user_registration_path, text: /sign up/i
    assert_select "a[href=?]", tests_test_attempts_path, count: 0
  end

  test "should show admin navigation for admin users" do
    sign_in @admin
    get root_path
    assert_response :success
    
    # Should show admin dropdown
    assert_select "a[href=?]", admin_root_path, text: /admin/i
  end

  test "should not show admin navigation for regular users" do
    sign_in @user
    get root_path
    assert_response :success
    
    # Should not show admin dropdown
    assert_select "a[href=?]", admin_root_path, count: 0
  end

  test "should validate user registration fields" do
    get new_user_registration_path
    assert_response :success

    # Test invalid email
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          email: "invalid_email",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    # Test password mismatch
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "different_password"
        }
      }
    end

    # Test weak password
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          email: "test@example.com",
          password: "123",
          password_confirmation: "123"
        }
      }
    end
  end
end
