class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      total_users: User.count,
      total_courses: Course.count,
      total_tests: Test.count,
      total_questions: Question.count,
      total_test_attempts: TestAttempt.count,
      recent_users: User.order(created_at: :desc).limit(5),
      recent_test_attempts: TestAttempt.includes(:user, :test).order(taken_at: :desc).limit(5)
    }
  end
end
