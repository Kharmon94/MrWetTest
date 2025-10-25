class StripeService
  class << self
    def create_payment_intent(amount, currency, metadata = {})
      Stripe::PaymentIntent.create({
        amount: (amount * 100).to_i, # Convert to cents
        currency: currency,
        metadata: metadata,
        automatic_payment_methods: {
          enabled: true,
        },
      })
    end

    def retrieve_payment_intent(payment_intent_id)
      Stripe::PaymentIntent.retrieve(payment_intent_id)
    end

    def confirm_payment_intent(payment_intent_id, payment_method_id = nil)
      intent_params = { id: payment_intent_id }
      intent_params[:payment_method] = payment_method_id if payment_method_id
      
      Stripe::PaymentIntent.confirm(intent_params)
    end

    def cancel_payment_intent(payment_intent_id)
      Stripe::PaymentIntent.cancel(payment_intent_id)
    end

    def create_customer(email, name = nil)
      customer_params = { email: email }
      customer_params[:name] = name if name
      
      Stripe::Customer.create(customer_params)
    end

    def retrieve_customer(customer_id)
      Stripe::Customer.retrieve(customer_id)
    end

    def create_price(amount, currency, product_id, metadata = {})
      Stripe::Price.create({
        unit_amount: (amount * 100).to_i,
        currency: currency,
        product: product_id,
        metadata: metadata,
      })
    end

    def create_product(name, description = nil)
      product_params = { name: name }
      product_params[:description] = description if description
      
      Stripe::Product.create(product_params)
    end

    def create_checkout_session(line_items, success_url, cancel_url, metadata = {})
      Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: line_items,
        mode: 'payment',
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: metadata,
      })
    end

    def retrieve_checkout_session(session_id)
      Stripe::Checkout::Session.retrieve(session_id)
    end

    def list_payment_methods(customer_id, type = 'card')
      Stripe::PaymentMethod.list({
        customer: customer_id,
        type: type,
      })
    end

    def attach_payment_method(payment_method_id, customer_id)
      Stripe::PaymentMethod.attach(
        payment_method_id,
        { customer: customer_id }
      )
    end

    def detach_payment_method(payment_method_id)
      Stripe::PaymentMethod.detach(payment_method_id)
    end

    def create_refund(payment_intent_id, amount = nil, reason = nil)
      refund_params = { payment_intent: payment_intent_id }
      refund_params[:amount] = (amount * 100).to_i if amount
      refund_params[:reason] = reason if reason
      
      Stripe::Refund.create(refund_params)
    end

    def list_charges(limit = 100, customer_id = nil)
      params = { limit: limit }
      params[:customer] = customer_id if customer_id
      
      Stripe::Charge.list(params)
    end

    def retrieve_charge(charge_id)
      Stripe::Charge.retrieve(charge_id)
    end

    def construct_webhook_event(payload, sig_header, webhook_secret)
      Stripe::Webhook.construct_event(
        payload,
        sig_header,
        webhook_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid payload: #{e.message}"
      nil
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Invalid signature: #{e.message}"
      nil
    end

    def handle_webhook_event(event)
      case event.type
      when 'payment_intent.succeeded'
        handle_payment_succeeded(event.data.object)
      when 'payment_intent.payment_failed'
        handle_payment_failed(event.data.object)
      when 'payment_intent.canceled'
        handle_payment_canceled(event.data.object)
      when 'checkout.session.completed'
        handle_checkout_completed(event.data.object)
      else
        Rails.logger.info "Unhandled event type: #{event.type}"
      end
    end

    private

    def handle_payment_succeeded(payment_intent)
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
      return unless payment

      payment.update!(
        status: 'succeeded',
        metadata: payment_intent.metadata
      )

      # Grant access to the purchased item
      grant_access_to_purchase(payment)
    end

    def handle_payment_failed(payment_intent)
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
      return unless payment

      payment.update!(status: 'failed')
    end

    def handle_payment_canceled(payment_intent)
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
      return unless payment

      payment.update!(status: 'canceled')
    end

    def handle_checkout_completed(session)
      # Find payment by checkout session ID
      payment = Payment.find_by(stripe_checkout_session_id: session.id)
      
      unless payment
        Rails.logger.error "Payment not found for checkout session: #{session.id}"
        return
      end

      # Update payment with payment intent ID from session
      payment.update!(
        stripe_payment_intent_id: session.payment_intent,
        status: 'succeeded',
        metadata: session.metadata || {}
      )

      # Grant access to the purchased item
      grant_access_to_purchase(payment)
      
      Rails.logger.info "Checkout session completed successfully: #{session.id}"
    end

    def grant_access_to_purchase(payment)
      case payment.payable_type
      when 'Course'
        # Create course enrollment or mark as purchased
        Rails.logger.info "Granting access to course: #{payment.payable_id}"
      when 'Test'
        # Grant test access
        Rails.logger.info "Granting access to test: #{payment.payable_id}"
      end
    end
  end
end
