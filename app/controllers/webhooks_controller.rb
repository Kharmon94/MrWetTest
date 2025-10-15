class WebhooksController < ApplicationController
  protect_from_forgery with: :null_session
  
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_secret = Rails.application.config.stripe_webhook_secret

    if webhook_secret.blank?
      Rails.logger.error "Stripe webhook secret not configured"
      render json: { error: "Webhook secret not configured" }, status: 500
      return
    end

    begin
      event = StripeService.construct_webhook_event(payload, sig_header, webhook_secret)
      
      if event.nil?
        Rails.logger.error "Failed to construct webhook event"
        render json: { error: "Invalid webhook event" }, status: 400
        return
      end

      # Handle the webhook event
      StripeService.handle_webhook_event(event)

      Rails.logger.info "Successfully handled webhook event: #{event.type}"
      render json: { received: true }

    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Invalid signature: #{e.message}"
      render json: { error: "Invalid signature" }, status: 400
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid payload: #{e.message}"
      render json: { error: "Invalid payload" }, status: 400
    rescue StandardError => e
      Rails.logger.error "Webhook error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Webhook processing failed" }, status: 500
    end
  end

  private

  def verify_webhook_signature(payload, signature, secret)
    Stripe::Webhook.construct_event(payload, signature, secret)
  end
end
