require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:student)
    @user.add_role(:student) unless @user.has_role?(:student)
    @course = courses(:one)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require an email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should validate email format" do
    @user.email = "invalid_email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "should validate theme_preference inclusion" do
    @user.theme_preference = "invalid"
    assert_not @user.valid?
    assert_includes @user.errors[:theme_preference], "is not included in the list"
  end

  test "should accept valid theme_preferences" do
    valid_themes = %w[light dark auto]
    valid_themes.each do |theme|
      @user.theme_preference = theme
      assert @user.valid?, "#{theme} should be valid"
    end
  end

  test "should validate language inclusion" do
    @user.language = "invalid"
    assert_not @user.valid?
    assert_includes @user.errors[:language], "is not included in the list"
  end

  test "should accept valid languages" do
    valid_languages = %w[en es fr de zh ja]
    valid_languages.each do |lang|
      @user.language = lang
      assert @user.valid?, "#{lang} should be valid"
    end
  end

  test "should have role assignment methods" do
    assert_respond_to @user, :add_role
    assert_respond_to @user, :has_role?
    assert_respond_to @user, :roles
  end

  test "should support admin role" do
    admin_user = users(:admin)
    admin_user.add_role(:admin) unless admin_user.has_role?(:admin)
    assert admin_user.has_role?(:admin)
  end

  test "should support student role" do
    assert @user.has_role?(:student)
  end

  test "should not support instructor role" do
    # Instructor role should not exist in the system
    assert_not @user.has_role?(:instructor)
  end

  test "has_purchased? should return false for non-purchased items" do
    # User has no payments, so should not have purchased the course
    assert_not @user.has_purchased?(@course)
  end

  test "has_purchased? should return true for purchased items" do
    # Create a successful payment
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: @course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_user_test_123')
    assert @user.has_purchased?(@course)
  end

  test "can_access? should return true for admins" do
    admin_user = users(:admin)
    admin_user.add_role(:admin) unless admin_user.has_role?(:admin)
    assert admin_user.can_access?(@course)
  end

  test "can_access? should return true for free courses" do
    @course.price = 0
    assert @user.can_access?(@course)
  end

  test "can_access? should return false for non-purchased paid courses" do
    @course.price = 100
    # User has no payments, so should not have access to paid course
    assert_not @user.can_access?(@course)
  end

  test "can_access? should return true for purchased courses" do
    @course.price = 100
    # Create a successful payment for this course
    Payment.create!(user: @user, payable: @course, status: 'succeeded', amount: 100,
                   currency: 'usd', stripe_payment_intent_id: 'pi_user_test_123')
    assert @user.can_access?(@course)
  end

  test "should have test_attempts association" do
    assert_respond_to @user, :test_attempts
  end

  test "should have payments association" do
    assert_respond_to @user, :payments
  end

  test "should have avatar attachment" do
    assert_respond_to @user, :avatar
  end
end
