module SecurityCompliance
  extend ActiveSupport::Concern

  included do
    before_action :log_security_events, if: :user_signed_in?
    before_action :protect_pii, if: :user_signed_in?
  end

  private

  def log_security_events
    # Log security events for compliance tracking
    if assessment_related_request?
      # Create a simple log entry instead of using the service method
      Rails.logger.info "Security Access Event: User #{current_user.id} accessing assessment-related path #{request.path} at #{Time.current}"
      Rails.logger.info "Security Data: IP=#{request.remote_ip}, UserAgent=#{request.user_agent}, Method=#{request.method}"
    end
  end

  def protect_pii
    # Implement PII protection measures
    # This could include encryption, access logging, etc.
    if sensitive_data_request?
      # Log access to sensitive data
      Rails.logger.info "PII Access: User #{current_user.id} accessing sensitive data at #{Time.current}"
    end
  end

  def assessment_related_request?
    # Check if request is assessment-related
    assessment_paths = [
      /^\/tests\/test_attempts/,
      /^\/assessment_compliance/,
      /^\/tests\//,
      /^\/courses\/\d+\/tests/
    ]

    current_path = request.path
    assessment_paths.any? { |pattern| current_path.match?(pattern) }
  end

  def sensitive_data_request?
    # Check if request involves sensitive data
    sensitive_paths = [
      /^\/admin\/users/,
      /^\/admin\/test_attempts/,
      /^\/users\/\d+/,
      /^\/tests\/test_attempts\/\d+/
    ]

    current_path = request.path
    sensitive_paths.any? { |pattern| current_path.match?(pattern) }
  end

  def secure_assessment_headers
    # Set security headers for assessments
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
  end

  def validate_assessment_integrity(test_attempt)
    # Validate assessment integrity checks
    return true unless test_attempt.test.final_assessment?

    # Check for suspicious patterns (simplified implementation)
    integrity_checks = {
      time_consistency: check_time_consistency(test_attempt),
      answer_patterns: check_answer_patterns(test_attempt),
      session_validity: check_session_validity(test_attempt)
    }

    # Log integrity check results
    AssessmentComplianceService.log_assessment_event(:integrity_check, test_attempt, integrity_checks)

    integrity_checks.values.all?
  end

  private

  def check_time_consistency(test_attempt)
    # Check if time spent on assessment is reasonable
    return true unless test_attempt.start_time && test_attempt.end_time

    duration = test_attempt.end_time - test_attempt.start_time
    expected_min_duration = test_attempt.test_attempt_questions.count * 30 # 30 seconds per question minimum
    
    duration >= expected_min_duration
  end

  def check_answer_patterns(test_attempt)
    # Check for suspicious answer patterns
    answers = test_attempt.test_attempt_questions.pluck(:chosen_answer)
    
    # Simple check: not all answers should be identical
    answers.uniq.count > 1
  end

  def check_session_validity(test_attempt)
    # Check if session is valid and consistent
    # This is a simplified implementation
    true
  end
end
