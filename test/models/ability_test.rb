require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin)
    @admin_user.add_role(:admin) unless @admin_user.has_role?(:admin)
    @student_user = users(:student)
    @student_user.add_role(:student) unless @student_user.has_role?(:student)
    @guest_user = User.new # Guest user (not persisted)
    @course = courses(:one)
    @test = tests(:one)
  end

  test "guest user should have limited permissions" do
    ability = Ability.new(@guest_user)
    
    # Can read courses and tests
    assert ability.can?(:read, Course)
    assert ability.can?(:read, Test)
    assert ability.can?(:browse, Course)
    
    # Cannot manage anything
    assert ability.cannot?(:create, Course)
    assert ability.cannot?(:update, Course)
    assert ability.cannot?(:destroy, Course)
    assert ability.cannot?(:manage, :all)
  end

  test "admin user should have full access" do
    ability = Ability.new(@admin_user)
    
    # Can manage everything
    assert ability.can?(:manage, :all)
    assert ability.can?(:create, Course)
    assert ability.can?(:update, Course)
    assert ability.can?(:destroy, Course)
    assert ability.can?(:create, Test)
    assert ability.can?(:update, Test)
    assert ability.can?(:destroy, Test)
    assert ability.can?(:manage, User)
  end

  test "student user should have appropriate permissions" do
    ability = Ability.new(@student_user)
    
    # Can read and browse courses
    assert ability.can?(:read, Course)
    assert ability.can?(:browse, Course)
    assert ability.can?(:show, Course)
    
    # Cannot manage courses
    assert ability.cannot?(:create, Course)
    assert ability.cannot?(:update, Course)
    assert ability.cannot?(:destroy, Course)
  end

  test "student user should only access tests from enrolled courses" do
    ability = Ability.new(@student_user)
    
    # Create payment to make user enrolled
    Payment.create!(user: @student_user, payable: @test.course, status: 'succeeded', amount: @test.course.price,
                   currency: 'usd', stripe_payment_intent_id: 'pi_ability_test_123')
    
    assert ability.can?(:read, @test)
    assert ability.can?(:show, @test)
  end

  test "student user should manage their own test attempts" do
    ability = Ability.new(@student_user)
    
    # Can create test attempts
    assert ability.can?(:create, TestAttempt)
    
    # Can read and show their own test attempts
    assert ability.can?(:read, TestAttempt.new(user: @student_user))
    assert ability.can?(:index, TestAttempt.new(user: @student_user))
    assert ability.can?(:show, TestAttempt.new(user: @student_user))
    
    # Can update non-submitted attempts
    non_submitted = TestAttempt.new(user: @student_user, submitted: false)
    assert ability.can?(:update, non_submitted)
    assert ability.can?(:edit, non_submitted)
    
    # Cannot update submitted attempts
    submitted = TestAttempt.new(user: @student_user, submitted: true)
    assert ability.cannot?(:update, submitted)
    assert ability.cannot?(:edit, submitted)
  end

  test "student user should manage their own payments" do
    ability = Ability.new(@student_user)
    
    # Can create payments
    assert ability.can?(:create, Payment)
    assert ability.can?(:new, Payment)
    
    # Can read and show their own payments
    own_payment = Payment.new(user: @student_user)
    assert ability.can?(:read, own_payment)
    assert ability.can?(:index, own_payment)
    assert ability.can?(:show, own_payment)
    assert ability.can?(:confirm, own_payment)
    assert ability.can?(:success, own_payment)
    assert ability.can?(:cancel, own_payment)
  end

  test "student user should manage their own profile" do
    ability = Ability.new(@student_user)
    
    # Can read, update, and edit their own profile
    assert ability.can?(:read, @student_user)
    assert ability.can?(:update, @student_user)
    assert ability.can?(:edit, @student_user)
    
    # Cannot manage other users
    other_user = User.new
    assert ability.cannot?(:read, other_user)
    assert ability.cannot?(:update, other_user)
    assert ability.cannot?(:edit, other_user)
  end

  test "student user should manage their own settings" do
    ability = Ability.new(@student_user)
    
    assert ability.can?(:read, :settings)
    assert ability.can?(:update, :settings)
    assert ability.can?(:edit, :settings)
  end

  test "student user should access assessment compliance features" do
    ability = Ability.new(@student_user)
    
    # Can access honor statement features
    assert ability.can?(:show_procedures, Test)
    assert ability.can?(:show_honor_statement, Test)
    assert ability.can?(:accept_honor, Test)
    
    # Can abandon their own assessments
    own_attempt = TestAttempt.new(user: @student_user)
    assert ability.can?(:abandon_assessment, own_attempt)
  end

  test "instructor role should not exist in permissions" do
    ability = Ability.new(@student_user)
    
    # Verify no instructor-specific permissions exist
    # Student should not have instructor permissions
    assert ability.cannot?(:manage, Course)
    assert ability.cannot?(:manage, Test)
    assert ability.cannot?(:manage, User)
  end

  test "user without roles should have student permissions" do
    user_without_roles = User.new
    user_without_roles.roles = []
    
    ability = Ability.new(user_without_roles)
    
    # Should have same permissions as student
    assert ability.can?(:read, Course)
    assert ability.can?(:browse, Course)
    assert ability.cannot?(:manage, :all)
  end
end
