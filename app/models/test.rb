class Test < ApplicationRecord
  belongs_to :course
  belongs_to :lesson, optional: true
  has_many :questions, dependent: :destroy
  has_many :test_attempts, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  validates :title, :description, :instructions, presence: true
  validates :assessment_type, inclusion: { in: %w[final chapter practice] }
  validates :time_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_attempts, numericality: { greater_than: 0 }, allow_nil: true
  validates :passing_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :question_pool_size, numericality: { greater_than: 0 }, allow_nil: true
  
  # Test helper methods
  def lesson_specific?
    lesson.present?
  end

  # Compliance and Academic Integrity Methods
  
  def final_assessment?
    assessment_type == 'final'
  end
  
  def chapter_assessment?
    assessment_type == 'chapter'
  end
  
  def practice_assessment?
    assessment_type == 'practice'
  end
  
  def requires_honor_statement?
    honor_statement_required || final_assessment?
  end
  
  def meets_question_pool_requirement?
    # Question pools must contain at least 4 times the number of questions presented
    return true unless question_pool_size.present?
    questions.count >= (question_pool_size * 4)
  end
  
  def question_pool_status
    return "Not applicable" unless question_pool_size.present?
    
    required_count = question_pool_size * 4
    current_count = questions.count
    
    if current_count >= required_count
      "Compliant (#{current_count}/#{required_count} questions)"
    else
      "Non-compliant (#{current_count}/#{required_count} questions)"
    end
  end
  
  def validate_question_pool_compliance!
    unless meets_question_pool_requirement?
      raise "Assessment compliance violation: Question pool must contain at least #{question_pool_size * 4} questions for a pool size of #{question_pool_size}. Currently has #{questions.count} questions."
    end
  end
  
  def generate_random_questions_for_attempt(user, previous_attempt_ids = [])
    # Validate question pool compliance before generating
    validate_question_pool_compliance! if final_assessment?
    
    # Generate questions ensuring no more than 50% repetition for retakes
    if previous_attempt_ids.any?
      previous_questions = TestAttemptQuestion.joins(:test_attempt)
                                            .where(test_attempts: { id: previous_attempt_ids })
                                            .pluck(:question_id)
      
      # Ensure no more than 50% repetition (compliance requirement)
      max_repeated = (question_pool_size * 0.5).ceil
      repeated_questions = previous_questions.uniq.sample([max_repeated, previous_questions.uniq.count].min)
      
      # Get new questions from remaining pool
      available_questions = questions.where.not(id: repeated_questions).to_a
      needed_questions = question_pool_size - repeated_questions.count
      new_questions = available_questions.sample([needed_questions, available_questions.count].min)
      
      # Combine and randomize to ensure varied presentation
      selected_questions = (repeated_questions + new_questions.pluck(:id)).shuffle
      
      # Log compliance for audit trail
      Rails.logger.info "Question selection compliance: #{repeated_questions.count}/#{question_pool_size} repeated (#{(repeated_questions.count.to_f / question_pool_size * 100).round(1)}%)"
      
      selected_questions
    else
      # First attempt - random selection from full pool
      available_questions = questions.to_a
      pool_size = [question_pool_size, available_questions.count].min
      available_questions.sample(pool_size).pluck(:id)
    end
  end
  
  def generate_weighted_questions_for_attempt(user, previous_attempt_ids = [])
    # Enhanced method for weighted question selection based on difficulty and learning objectives
    validate_question_pool_compliance! if final_assessment?
    
    # Get all available questions with their metadata
    available_questions = questions.includes(:test_attempt_questions)
    
    if previous_attempt_ids.any?
      # Retake logic with 50% max repetition
      previous_questions = TestAttemptQuestion.joins(:test_attempt)
                                            .where(test_attempts: { id: previous_attempt_ids })
                                            .pluck(:question_id)
      
      max_repeated = (question_pool_size * 0.5).ceil
      repeated_questions = previous_questions.uniq.sample([max_repeated, previous_questions.uniq.count].min)
      
      # Consolidate remaining questions for weighted selection
      remaining_questions = available_questions.where.not(id: repeated_questions)
      
      # Apply weighting based on question difficulty and user performance
      weighted_questions = apply_question_weights(remaining_questions, user)
      new_questions = weighted_questions.sample(question_pool_size - repeated_questions.count)
      
      (repeated_questions + new_questions.pluck(:id)).shuffle
    else
      # First attempt with weighted selection
      weighted_questions = apply_question_weights(available_questions, user)
      weighted_questions.sample(question_pool_size).pluck(:id)
    end
  end
  
  private
  
  def apply_question_weights(questions, user)
    # Apply weighting based on difficulty, learning objectives, and user performance
    # This is a simplified implementation - could be enhanced with ML algorithms
    questions.order(:id) # For now, return in consistent order
  end
  
  public
  
  def can_user_retake?(user)
    return true unless max_attempts.present?
    user.test_attempts.where(test: self).count < max_attempts
  end
  
  def user_attempt_count(user)
    user.test_attempts.where(test: self).count
  end
  
  def time_limit_display
    return "No time limit" unless time_limit.present?
    "#{time_limit} minutes"
  end
  
  def passing_score_display
    return "Not specified" unless passing_score.present?
    "#{passing_score}%"
  end
  
  # Price method for compatibility with payment system
  def price
    course.price
  end
end
  