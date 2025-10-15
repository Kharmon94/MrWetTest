module Instructor
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_instructor

    def index
      @instructor = current_user
      
      # Get instructor's courses
      @courses = Course.all # For now, all instructors can see all courses
      @total_courses = @courses.count
      
      # Get all tests
      @tests = Test.all
      @total_tests = @tests.count
      
      # Get student statistics
      @total_students = User.joins(:roles).where(roles: { name: 'student' }).count
      
      # Get recent test attempts
      @recent_attempts = TestAttempt.includes(:user, :test)
                                   .joins(:user)
                                   .where(submitted: true)
                                   .order(taken_at: :desc)
                                   .limit(10)
      
      # Get course enrollment statistics
      @course_enrollments = {}
      @courses.each do |course|
        enrolled_count = Payment.where(payable: course, status: 'succeeded').count
        @course_enrollments[course.id] = enrolled_count
      end
      
      # Get test completion statistics
      @test_completions = {}
      @tests.each do |test|
        completed_count = TestAttempt.where(test: test, submitted: true).count
        @test_completions[test.id] = completed_count
      end
    end

    private

    def ensure_instructor
      unless current_user.has_role?(:instructor) || current_user.has_role?(:admin)
        redirect_to root_path, alert: "Access denied. Instructor privileges required."
      end
    end
  end
end
