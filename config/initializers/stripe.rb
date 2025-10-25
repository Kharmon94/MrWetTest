# Stripe configuration
# 
# Test Mode Setup Instructions:
# 1. Get test keys from Stripe Dashboard (https://dashboard.stripe.com/test/apikeys)
# 2. Edit credentials: EDITOR="code --wait" rails credentials:edit
# 3. Add the following structure:
#    stripe:
#      publishable_key: pk_test_YOUR_KEY_HERE
#      secret_key: sk_test_YOUR_KEY_HERE
#      webhook_secret: whsec_YOUR_WEBHOOK_SECRET_HERE
#
# Test Card Numbers:
# - Success: 4242 4242 4242 4242
# - Decline: 4000 0000 0000 0002
# - 3D Secure: 4000 0000 0000 3220

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