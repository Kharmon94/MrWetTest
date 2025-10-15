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
    # Return empty relation since tests are not directly associated with courses
    Test.none
  end
  
  def final_assessment
    # Return nil since tests are not directly associated with courses
    nil
  end
  
  def user_has_completed_all_chapters?(user)
    return true unless requires_chapter_assessments?
    
    # Since tests are not directly associated with courses, return true for now
    # This can be enhanced when the course-test relationship is properly established
    true
  end
  
  def user_can_take_final_assessment?(user)
    return true unless requires_chapter_assessments?
    user_has_completed_all_chapters?(user)
  end
  
  def chapter_completion_status(user)
    return {} unless requires_chapter_assessments?
    
    # Since tests are not directly associated with courses, return empty status
    # This can be enhanced when the course-test relationship is properly established
    status = {}
    lessons.each_with_index do |lesson, index|
      chapter_number = index + 1
      status[chapter_number] = {
        completed: false,
        score: 0,
        attempts: 0
      }
    end
    
    status
  end
end
