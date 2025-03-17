class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new  # guest user

    # Allow guest users to read courses and tests.
    if user.new_record?
      can :read, Course
      can :read, Test
    end

    if user.has_role?(:admin)
      can :manage, :all
    else
      # Regular users can create a test attempt.
      can :create, TestAttempt

      # Regular users can view (read/index) their own test attempts.
      can [:read, :index], TestAttempt, user_id: user.id

      # Regular users can update/edit their test attempts only if they haven't been submitted.
      can [:update, :edit], TestAttempt, user_id: user.id, submitted: false

      # Additionally, allow regular users to read courses and tests.
      can :read, Course
      can :read, Test
    end
  end
end
