class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy
  has_one_attached :thumbnail
  
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  
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
end
