class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy
  has_one_attached :thumbnail
  
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :time_managed, inclusion: { in: [true, false] }
  validates :chapter_assessments_required, inclusion: { in: [true, false] }
  
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
  
  def chapter_tests
    Test.joins("JOIN lessons ON lessons.course_id = #{id}")
        .where(assessment_type: 'chapter')
        .where("tests.title LIKE ? OR tests.description LIKE ?", "%chapter%", "%lesson%")
  end
  
  def final_assessment
    Test.where(assessment_type: 'final')
        .where("tests.title LIKE ? OR tests.description LIKE ?", "%#{title}%", "%final%")
        .first
  end
  
  def user_has_completed_all_chapters?(user)
    return true unless requires_chapter_assessments?
    
    chapter_tests.all? do |test|
      user.test_attempts.where(test: test, submitted: true)
          .where("score >= ?", test.passing_score || 70)
          .exists?
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
      test = chapter_tests.find { |t| t.title.downcase.include?("chapter #{chapter_number}") || 
                                     t.title.downcase.include?("lesson #{chapter_number}") }
      
      if test
        latest_attempt = user.test_attempts.where(test: test, submitted: true).order(:created_at).last
        status[chapter_number] = {
          completed: latest_attempt&.passed? || false,
          score: latest_attempt&.score || 0,
          attempts: user.test_attempts.where(test: test).count
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
end
