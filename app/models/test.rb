class Test < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :test_attempts, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  validates :title, :description, :instructions, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
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
end
  