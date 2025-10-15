class User < ApplicationRecord
  rolify

  has_many :test_attempts, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :payments, dependent: :destroy

  # Active Storage attachments
  has_one_attached :avatar

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Stripe customer ID for payment processing
  attribute :stripe_customer_id, :string

  # User preferences
  validates :theme_preference, inclusion: { in: %w[light dark auto], allow_blank: true }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true }
  validates :language, inclusion: { in: %w[en es fr de zh ja], allow_blank: true }

  # Instance methods for payment functionality
  def stripe_customer
    return nil unless stripe_customer_id.present?
    
    begin
      StripeService.retrieve_customer(stripe_customer_id)
    rescue Stripe::StripeError => e
      Rails.logger.error "Error retrieving Stripe customer: #{e.message}"
      nil
    end
  end

  def create_stripe_customer
    return stripe_customer_id if stripe_customer_id.present?
    
    begin
      customer = StripeService.create_customer(email, email)
      update!(stripe_customer_id: customer.id)
      customer.id
    rescue Stripe::StripeError => e
      Rails.logger.error "Error creating Stripe customer: #{e.message}"
      nil
    end
  end

  def has_purchased?(payable)
    return false unless payable.present?
    
    payments.successful.exists?(payable: payable)
  end

  def can_access?(payable)
    return true if has_role?(:admin) # Admins can access everything
    return true unless payable.price.present? && payable.price > 0 # Free items
    return has_purchased?(payable) # Check if purchased
  end

  def purchased_courses
    # Get courses that user has purchased or that are free
    successful_payment_courses = Course.joins(:payments)
                                      .where(payments: { user_id: id, status: 'succeeded' })
                                      .distinct
    
    free_courses = Course.where(price: [nil, 0])
    
    # Combine purchased and free courses, removing duplicates
    Course.where(id: (successful_payment_courses.pluck(:id) + free_courses.pluck(:id)).uniq)
  end
end
