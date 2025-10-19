class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :tests, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy
  has_one_attached :thumbnail
  
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :time_managed, inclusion: { in: [true, false] }, allow_nil: true
  validates :chapter_assessments_required, inclusion: { in: [true, false] }, allow_nil: true
  
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
    "price_#{id}_#{created_at.to_i}"
  end

  # Chapter Assessment Methods
  
  def time_managed?
    time_managed
  end
  
  def requires_chapter_assessments?
    chapter_assessments_required || time_managed?
  end
  
  
  def lesson_tests(lesson)
    tests.where(lesson: lesson)
  end
  
  def chapter_tests
    tests.where(assessment_type: 'chapter')
  end
  
  def final_assessment
    tests.find_by(assessment_type: 'final')
  end
  
  def user_has_completed_all_chapters?(user)
    return true unless requires_chapter_assessments?
    
    chapter_tests.all? do |test|
      user.test_attempts.where(test: test, submitted: true).exists?
    end
  end
  
  def user_can_take_final_assessment?(user)
    return true unless requires_chapter_assessments?
    user_has_completed_all_chapters?(user)
  end
  
  def chapter_completion_status(user)
    return {} unless requires_chapter_assessments?
    
    status = {}
    lessons.each_with_index do |lesson, index|
      chapter_number = index + 1
      lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
      
      if lesson_test
        attempts = user.test_attempts.where(test: lesson_test)
        latest_attempt = attempts.order(created_at: :desc).first
        
        status[chapter_number] = {
          completed: latest_attempt&.submitted? || false,
          score: latest_attempt&.score || 0,
          attempts: attempts.count
        }
      else
        status[chapter_number] = {
          completed: false,
          score: 0,
          attempts: 0
        }
      end
    end
    
    status
  end

  def user_completion_status(user)
    attempts = user.test_attempts.where(test: tests)
    
    if attempts.empty?
      :not_started
    elsif attempts.any?(&:submitted?)
      :completed
    else
      :in_progress
    end
  end

  def user_completion_percentage(user)
    attempts = user.test_attempts.where(test: tests)
    return 0 if attempts.empty?
    
    submitted_attempts = attempts.where(submitted: true)
    return 0 if tests.empty?
    
    (submitted_attempts.count.to_f / tests.count * 100).round
  end

  def user_has_passed?(user)
    attempts = user.test_attempts.where(test: tests)
    return false if attempts.empty?
    
    attempts.any? do |attempt|
      attempt.submitted? && attempt.score && attempt.score >= (attempt.test.passing_score || 70)
    end
  end
end
