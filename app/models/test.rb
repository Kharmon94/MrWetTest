class Test < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :test_attempts, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  validates :title, :description, :instructions, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :assessment_type, inclusion: { in: %w[final chapter practice] }
  validates :time_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_attempts, numericality: { greater_than: 0 }, allow_nil: true
  validates :passing_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :question_pool_size, numericality: { greater_than: 0 }, allow_nil: true
  
  # Payment-related methods
  def free?
    price.blank? || price == 0
  end
  
  def paid?
    !free?
  end
  
  def formatted_price
    return "Free" if free?
    "USD $#{sprintf('%.2f', price)}"
  end
  
  def stripe_price_id
    # This would be set when creating a Stripe product/price
    # For now, we'll generate it dynamically
    "price_test_#{id}_#{created_at.to_i}"
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
  
  def generate_random_questions_for_attempt(user, previous_attempt_ids = [])
    # Generate questions ensuring no more than 50% repetition for retakes
    if previous_attempt_ids.any?
      previous_questions = TestAttemptQuestion.joins(:test_attempt)
                                            .where(test_attempts: { id: previous_attempt_ids })
                                            .pluck(:question_id)
      
      # Ensure no more than 50% repetition
      max_repeated = (question_pool_size * 0.5).ceil
      repeated_questions = previous_questions.sample([max_repeated, previous_questions.count].min)
      
      # Get new questions
      new_questions = questions.where.not(id: repeated_questions).sample(question_pool_size - repeated_questions.count)
      
      # Combine and randomize
      (repeated_questions + new_questions.pluck(:id)).shuffle
    else
      # First attempt - random selection
      questions.sample(question_pool_size).pluck(:id)
    end
  end
  
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
end
  