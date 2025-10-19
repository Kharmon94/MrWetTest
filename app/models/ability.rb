class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new  # guest user

    # Guest users (not logged in)
    if user.new_record?
      can :read, Course
      can :read, Test
      can :browse, Course
      return
    end

    # Admin users have full access to everything
    if user.has_role?(:admin)
      can :manage, :all
      return
    end


    # Student/Regular user permissions
    if user.has_role?(:student) || user.roles.empty?
      # Course access
      can :read, Course
      can :browse, Course
      can :show, Course
      
      # Test access - only for enrolled courses
      can :read, Test do |test|
        user.has_purchased?(test.course)
      end
      can :show, Test do |test|
        user.has_purchased?(test.course)
      end
      
      # Test attempt management
      can :create, TestAttempt
      can [:read, :index], TestAttempt, user_id: user.id
      can [:update, :edit], TestAttempt, user_id: user.id, submitted: false
      can :show, TestAttempt, user_id: user.id
      
      # Payment management
      can [:read, :index], Payment, user_id: user.id
      can [:create, :new], Payment
      can [:show, :confirm, :success, :cancel], Payment, user_id: user.id
      
      # User profile management
      can [:read, :update, :edit], User, id: user.id
      
      # Settings management
      can [:read, :update, :edit], :settings if user.id == user.id
      
      # Assessment compliance
      can [:show_procedures, :show_honor_statement, :accept_honor], Test
      can :abandon_assessment, TestAttempt, user_id: user.id
    end
  end
end
