class AssessmentComplianceService
  HONOR_STATEMENT_TEXT = <<~STATEMENT
    ACADEMIC INTEGRITY HONOR STATEMENT

    I understand that this assessment is designed to evaluate my individual knowledge and understanding of the course material. By proceeding with this assessment, I affirm that:

    1. I will complete this assessment independently without assistance from other individuals, textbooks, notes, or electronic resources unless specifically authorized.

    2. I will not share, discuss, or reveal the content of this assessment with other students before, during, or after completion.

    3. I will not use any unauthorized aids, including but not limited to calculators, phones, tablets, or other electronic devices unless explicitly permitted.

    4. I understand that any violation of academic integrity may result in disciplinary action including but not limited to failure of the assessment, failure of the course, or other academic sanctions.

    5. I acknowledge that my work will be monitored and may be subject to review for academic integrity.

    By checking the box below and proceeding, I certify that I have read, understood, and agree to abide by these terms of academic integrity.
  STATEMENT

  ASSESSMENT_PROCEDURES_TEXT = <<~PROCEDURES
    ASSESSMENT PROCEDURES AND GUIDELINES

    Before beginning this assessment, please review the following important procedures:

    ASSESSMENT RULES:
    • This assessment must be completed independently without assistance
    • You cannot access course materials during the assessment
    • Once an answer is submitted, it cannot be changed
    • The assessment will be automatically graded with feedback provided
    • Time limits, if applicable, will be strictly enforced

    WHAT CONSTITUTES ABANDONING AN ASSESSMENT:
    • Closing the browser window or navigating away from the assessment
    • Exceeding the time limit (if applicable)
    • Refusing to accept the honor statement
    • Using unauthorized resources or assistance

    TECHNICAL REQUIREMENTS:
    • Ensure you have a stable internet connection
    • Do not use the browser's back button during the assessment
    • Save your progress frequently by answering questions
    • Contact technical support if you encounter issues

    RETAKES:
    • You may have limited retake attempts as specified for this assessment
    • Retakes will include different questions with no more than 50% repetition
    • Previous scores and attempts will be recorded

    By proceeding, you acknowledge that you have read and understood these procedures.
  PROCEDURES

  class << self
    def honor_statement_text
      HONOR_STATEMENT_TEXT
    end

    def assessment_procedures_text
      ASSESSMENT_PROCEDURES_TEXT
    end

    def validate_assessment_compliance(test, user)
      compliance_errors = []

      # Check if user has access
      unless user.can_access?(test)
        compliance_errors << "You do not have access to this assessment"
      end

      # Check retake limits
      unless test.can_user_retake?(user)
        compliance_errors << "You have reached the maximum number of attempts for this assessment"
      end

      # Check question pool requirements for final assessments
      if test.final_assessment? && !test.meets_question_pool_requirement?
        compliance_errors << "This assessment does not meet minimum question pool requirements"
      end

      compliance_errors
    end

    def generate_assessment_instructions(test, user)
      instructions = []
      
      instructions << "Assessment Type: #{test.assessment_type.titleize}"
      instructions << "Time Limit: #{test.time_limit_display}"
      instructions << "Passing Score: #{test.passing_score_display}"
      
      if test.max_attempts.present?
        remaining = test.max_attempts - test.user_attempt_count(user)
        instructions << "Remaining Attempts: #{remaining}"
      end
      
      if test.final_assessment?
        instructions << "This is a final assessment with enhanced security measures"
        instructions << "Question pool contains #{test.questions.count} questions"
      end
      
      instructions
    end

    def log_assessment_event(event_type, test_attempt, additional_data = {})
      # Log compliance events for audit trail
      if test_attempt
        Rails.logger.info "Assessment Event: #{event_type} - User: #{test_attempt.user.email}, Test: #{test_attempt.test.title}, Time: #{Time.current}"
      else
        Rails.logger.info "Assessment Event: #{event_type} - Time: #{Time.current}"
      end
      Rails.logger.info "Additional Data: #{additional_data.to_json}" if additional_data.any?
    end

    def enforce_security_measures(test_attempt)
      # Implement security measures for final assessments
      return unless test_attempt.test.final_assessment?
      
      # Log security events
      log_assessment_event(:security_check, test_attempt, {
        ip_address: test_attempt.user.current_sign_in_ip,
        user_agent: test_attempt.user.current_sign_in_at,
        timestamp: Time.current
      })
    end
  end
end
