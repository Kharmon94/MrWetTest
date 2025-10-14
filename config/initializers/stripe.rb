# Stripe configuration
if Rails.application.credentials.stripe.present?
  Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  
  # Set the publishable key for use in JavaScript
  Rails.application.config.stripe_publishable_key = Rails.application.credentials.stripe[:publishable_key]
  
  # Configure webhook endpoint secret
  Rails.application.config.stripe_webhook_secret = Rails.application.credentials.stripe[:webhook_secret]
else
  # Set default values when credentials are not configured
  Rails.application.config.stripe_publishable_key = nil
  Rails.application.config.stripe_webhook_secret = nil
end

# Set Stripe API version
Stripe.api_version = '2024-12-18.acacia' 