ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    
    def setup
      super
      # Ensure valid BCrypt passwords for test users
      admin_user = users(:admin)
      student_user = users(:student)
      
      admin_user.password = 'password123'
      admin_user.password_confirmation = 'password123'
      admin_user.save!(validate: false)
      
      student_user.password = 'password123'
      student_user.password_confirmation = 'password123'
      student_user.save!(validate: false)
    end
  end
end
