class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new  # guest user

    # Allow guest users to read courses.
    if user.new_record?
      can :read, Course
    end

    # Admin users can do everything.
    if user.has_role?(:admin)
      can :manage, :all
    else
      # Regular users can create assessments.
      can :create, Assessment

      # Regular users can view (read and index) assessments they own.
      can [:read, :index], Assessment, user_id: user.id

      # Regular users can update or edit an assessment only if it hasn't been submitted.
      can [:update, :edit], Assessment, user_id: user.id, submitted: false

      # Allow regular users to read courses.
      can :read, Course
    end
  end
end
