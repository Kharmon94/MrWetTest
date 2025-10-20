module AssessmentIsolation
  extend ActiveSupport::Concern

  included do
    before_action :check_assessment_isolation, if: :user_signed_in?, unless: :assessment_controller?
  end

  private

  def check_assessment_isolation
    # Check if user is currently taking an assessment
    active_attempt = current_user.test_attempts
                                .where(submitted: false)
                                .where(end_time: nil)
                                .includes(:test)
                                .first

    return unless active_attempt

    # Allow access to assessment-related pages
    return if assessment_related_path?

    # Block access to course materials during assessment
    if course_material_path?
      flash[:alert] = "Course materials are not accessible during assessments. Please complete or abandon your current assessment first."
      redirect_to edit_tests_test_attempt_path(active_attempt)
    end
  end

  def assessment_related_path?
    # Define paths that are allowed during assessments
    allowed_paths = [
      /^\/tests\/test_attempts/,
      /^\/assessment_compliance/,
      /^\/users\/sign_out/,
      /^\/up$/
    ]

    current_path = request.path
    allowed_paths.any? { |pattern| current_path.match?(pattern) }
  end

  def course_material_path?
    # Define paths that should be blocked during assessments
    blocked_paths = [
      /^\/courses\/\d+\/lessons/,
      /^\/lessons/,
      /^\/courses\/\d+$/,
      /^\/courses\/browse/,
      /^\/courses$/
    ]

    current_path = request.path
    blocked_paths.any? { |pattern| current_path.match?(pattern) }
  end

  def current_active_assessment
    return nil unless user_signed_in?
    
    current_user.test_attempts
                .where(submitted: false)
                .where('end_time IS NULL OR end_time > ?', Time.current)
                .includes(:test)
                .first
  end

  def assessment_in_progress?
    current_active_assessment.present?
  end

  def assessment_controller?
    # Define controllers that are part of the assessment flow and should not be isolated
    controller_path.start_with?('tests/test_attempts') ||
    controller_path.start_with?('assessment_compliance')
  end
end
