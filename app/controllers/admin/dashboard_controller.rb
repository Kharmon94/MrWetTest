class Admin::DashboardController < Admin::BaseController
  def index
    # Basic counts
    @total_users = User.count
    @total_courses = Course.count
    @total_tests = Test.count
    @total_questions = Question.count
    @total_test_attempts = TestAttempt.where(submitted: true).count
    
    # User statistics
    @admin_users = User.joins(:roles).where(roles: { name: 'admin' }).count
    @instructor_users = User.joins(:roles).where(roles: { name: 'instructor' }).count
    @student_users = User.joins(:roles).where(roles: { name: 'student' }).count
    
    # Course statistics
    @free_courses = Course.where(price: [nil, 0]).count
    @paid_courses = Course.where('price > 0').count
    @time_managed_courses = Course.where(time_managed: true).count
    
    # Test statistics
    @final_tests = Test.where(assessment_type: 'final').count
    @chapter_tests = Test.where(assessment_type: 'chapter').count
    @practice_tests = Test.where(assessment_type: 'practice').count
    
    # Financial statistics
    @total_revenue = Payment.where(status: 'succeeded').sum(:amount)
    @total_payments = Payment.where(status: 'succeeded').count
    @pending_payments = Payment.where(status: 'pending').count
    @failed_payments = Payment.where(status: ['failed', 'canceled']).count
    
    # Performance statistics
    @average_test_score = TestAttempt.where(submitted: true).average(:score)&.round(1) || 0
    @total_passed_attempts = TestAttempt.where(submitted: true).select { |ta| ta.passed? }.count
    @pass_rate = @total_test_attempts > 0 ? ((@total_passed_attempts.to_f / @total_test_attempts) * 100).round(1) : 0
    
    # Recent activity
    @recent_users = User.includes(:roles).order(created_at: :desc).limit(10)
    @recent_test_attempts = TestAttempt.includes(:user, :test)
                                     .where(submitted: true)
                                     .order(taken_at: :desc)
                                     .limit(10)
    @recent_payments = Payment.includes(:user, :payable)
                            .where(status: 'succeeded')
                            .order(created_at: :desc)
                            .limit(10)
    
    # Enrollment statistics by course
    @course_enrollments = Course.left_joins(:payments)
                               .where(payments: { status: 'succeeded' })
                               .group('courses.id', 'courses.title')
                               .count('payments.id')
    
    # Monthly statistics (last 6 months)
    @monthly_revenue = Payment.where(status: 'succeeded')
                            .where('created_at >= ?', 6.months.ago)
                            .group("DATE_TRUNC('month', created_at)")
                            .sum(:amount)
    
    @monthly_users = User.where('created_at >= ?', 6.months.ago)
                        .group("DATE_TRUNC('month', created_at)")
                        .count
    
    @monthly_attempts = TestAttempt.where(submitted: true)
                                  .where('taken_at >= ?', 6.months.ago)
                                  .group("DATE_TRUNC('month', taken_at)")
                                  .count
  end
end
