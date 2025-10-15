class Payment < ApplicationRecord
  belongs_to :user
  
  # Polymorphic association to track what the payment is for
  belongs_to :payable, polymorphic: true, optional: true
  
  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[usd eur gbp cad aud] }
  validates :status, presence: true, inclusion: { in: %w[pending succeeded failed canceled requires_payment_method requires_action] }
  validates :stripe_payment_intent_id, presence: true, uniqueness: true
  
  # Scopes
  scope :successful, -> { where(status: 'succeeded') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: ['failed', 'canceled']) }
  scope :recent, -> { order(created_at: :desc) }
  
  # JSON metadata field
  serialize :metadata, coder: JSON
  
  # Instance methods
  def successful?
    status == 'succeeded'
  end
  
  def failed?
    %w[failed canceled].include?(status)
  end
  
  def pending?
    status == 'pending'
  end
  
  def requires_action?
    status == 'requires_action'
  end
  
  def formatted_amount
    "#{currency.upcase} #{sprintf('%.2f', amount)}"
  end
  
  def payable_type_display
    case payable_type
    when 'Course'
      'Course Purchase'
    when 'Test'
      'Test Purchase'
    else
      payable_type || 'Payment'
    end
  end
end
