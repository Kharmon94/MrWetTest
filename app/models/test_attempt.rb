class TestAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :test
  has_many :test_attempt_questions, dependent: :destroy

  validates :retake_number, numericality: { greater_than_or_equal_to: 1 }
  validates :honor_statement_accepted, inclusion: { in: [true, false] }, allow_nil: true
  
  before_create :set_retake_number
  before_create :set_start_time
  after_create :generate_questions_for_attempt

  def calculate_score
    total = test_attempt_questions.count
    return 0 if total == 0
    
    correct = test_attempt_questions.includes(:question).select do |taq|
      taq.question.present? && taq.chosen_answer == taq.question.correct_answer
    end.count
    (correct.to_f / total * 100).round(2)
  end
  
  def passed?
    return false unless test.passing_score.present?
    calculate_score >= test.passing_score
  end
  
  def failed?
    !passed?
  end
  
  def time_remaining
    return nil unless test.time_limit.present? && start_time.present?
    elapsed_minutes = (Time.current - start_time) / 60
    remaining = test.time_limit - elapsed_minutes
    [remaining, 0].max
  end
  
  def duration_in_minutes
    return 0 unless start_time.present?
    end_time = self.end_time || taken_at
    ((end_time - start_time) / 60).round
  end
  
  def time_expired?
    return false unless test.time_limit.present? && start_time.present?
    time_remaining <= 0
  end
  
  def submit!
    # Lock all answers before submission (compliance requirement)
    lock_all_answers!
    
    self.end_time = Time.current
    self.score = calculate_score
    self.submitted = true
    save!
    
    # Log submission event for compliance tracking
    AssessmentComplianceService.log_assessment_event(:assessment_submitted, self, {
      score: self.score,
      duration_minutes: duration_minutes,
      questions_answered: test_attempt_questions.where.not(chosen_answer: nil).count,
      total_questions: test_attempt_questions.count
    })
  end
  
  def lock_all_answers!
    # Ensure all answers are locked and cannot be modified after submission
    test_attempt_questions.each do |taq|
      taq.update_column(:locked, true) if taq.respond_to?(:locked)
    end
  end
  
  def can_be_submitted?
    !submitted && honor_statement_accepted && !time_expired?
  end
  
  def duration_minutes
    return nil unless start_time.present? && end_time.present?
    ((end_time - start_time) / 60).round(2)
  end
  
  def questions_used_list
    return [] unless questions_used.present?
    JSON.parse(questions_used)
  end
  
  def previous_attempt_ids
    user.test_attempts.where(test: test)
        .where('id < ?', id)
        .pluck(:id)
  end

  private

  def set_retake_number
    self.retake_number = test.user_attempt_count(user) + 1
  end
  
  def set_start_time
    self.start_time = Time.current
  end
  
  def generate_questions_for_attempt
    # Generate random questions based on compliance rules
    question_ids = test.generate_random_questions_for_attempt(user, previous_attempt_ids)
    
    # Ensure we have at least one question
    if question_ids.empty?
      Rails.logger.warn "No questions generated for test attempt #{id}. Test #{test.id} has #{test.questions.count} questions."
      return
    end
    
    # Store the questions used for this attempt
    update_column(:questions_used, question_ids.to_json)
    
    # Create TestAttemptQuestion records
    question_ids.each do |question_id|
      # Verify the question exists before creating the association
      if Question.exists?(question_id)
        test_attempt_questions.create!(question_id: question_id)
      else
        Rails.logger.warn "Question #{question_id} does not exist for test attempt #{id}"
      end
    end
    
    # Log assessment event for compliance tracking
    AssessmentComplianceService.log_assessment_event(:questions_generated, self, {
      question_count: question_ids.count,
      is_retake: previous_attempt_ids.any?,
      repeated_questions: previous_attempt_ids.any? ? question_ids.count - (question_ids.count - previous_attempt_ids.count) : 0
    })
  end
end
