class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment, only: [:show, :confirm]
  before_action :set_payable_item, only: [:new, :create]

  def index
    @payments = current_user.payments.recent.includes(:payable)
    # Note: Kaminari pagination will be added when needed
    # @payments = @payments.page(params[:page])
  end

  def show
    @payment_intent = StripeService.retrieve_payment_intent(@payment.stripe_payment_intent_id) if @payment.stripe_payment_intent_id
  end

  def new
    # Check if user already has access
    if current_user.can_access?(@payable_item)
      redirect_to @payable_item, alert: "You already have access to this #{@payable_item.class.name.downcase}."
      return
    end

    # Check if user already has a pending payment for this item
    existing_payment = current_user.payments.pending.find_by(payable: @payable_item)
    if existing_payment
      redirect_to payment_path(existing_payment), notice: "You have a pending payment for this item."
      return
    end

    @payment = current_user.payments.build(
      payable: @payable_item,
      amount: @payable_item.price,
      currency: 'usd'
    )
  end

  def create
    # Check if user already has access
    if current_user.can_access?(@payable_item)
      redirect_to @payable_item, alert: "You already have access to this #{@payable_item.class.name.downcase}."
      return
    end

    # Check if user already has a pending payment for this item
    existing_payment = current_user.payments.pending.find_by(payable: @payable_item)
    if existing_payment
      redirect_to payment_path(existing_payment), notice: "You have a pending payment for this item."
      return
    end

    begin
      # Create Stripe customer if doesn't exist
      current_user.create_stripe_customer

      # Create payment intent
      payment_intent = StripeService.create_payment_intent(
        @payable_item.price,
        'usd',
        {
          user_id: current_user.id,
          payable_type: @payable_item.class.name,
          payable_id: @payable_item.id,
          payable_title: @payable_item.title
        }
      )

      # Create payment record
      @payment = current_user.payments.create!(
        stripe_payment_intent_id: payment_intent.id,
        payable: @payable_item,
        amount: @payable_item.price,
        currency: 'usd',
        status: 'pending',
        metadata: {
          payable_type: @payable_item.class.name,
          payable_id: @payable_item.id,
          payable_title: @payable_item.title
        }
      )

      redirect_to payment_path(@payment), notice: 'Payment initialized successfully.'

    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      redirect_to new_payment_path(payable_type: @payable_item.class.name, payable_id: @payable_item.id), 
                  alert: "Payment initialization failed: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Payment creation error: #{e.message}"
      redirect_to new_payment_path(payable_type: @payable_item.class.name, payable_id: @payable_item.id), 
                  alert: "An error occurred while creating the payment."
    end
  end

  def confirm
    payment_method_id = params[:payment_method_id]
    
    if payment_method_id.blank?
      redirect_to payment_path(@payment), alert: "Payment method is required."
      return
    end

    begin
      # Confirm the payment intent with the payment method
      payment_intent = StripeService.confirm_payment_intent(
        @payment.stripe_payment_intent_id,
        payment_method_id
      )

      # Update payment status
      @payment.update!(
        status: payment_intent.status,
        payment_method: payment_method_id
      )

      case payment_intent.status
      when 'succeeded'
        redirect_to @payment.payable, notice: 'Payment successful! You now have access to this content.'
      when 'requires_action'
        redirect_to payment_path(@payment), notice: 'Additional action required to complete payment.'
      else
        redirect_to payment_path(@payment), alert: "Payment status: #{payment_intent.status}"
      end

    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe confirmation error: #{e.message}"
      redirect_to payment_path(@payment), alert: "Payment confirmation failed: #{e.message}"
    end
  end

  def success
    @payment = current_user.payments.find_by(stripe_payment_intent_id: params[:payment_intent])
    
    if @payment&.successful?
      redirect_to @payment.payable, notice: 'Payment successful! You now have access to this content.'
    else
      redirect_to payments_path, alert: 'Payment not found or not successful.'
    end
  end

  def cancel
    @payment = current_user.payments.find_by(stripe_payment_intent_id: params[:payment_intent])
    
    if @payment
      @payment.update!(status: 'canceled')
      redirect_to payments_path, alert: 'Payment was canceled.'
    else
      redirect_to payments_path, alert: 'Payment not found.'
    end
  end

  private

  def set_payment
    @payment = current_user.payments.find(params[:id])
  end

  def set_payable_item
    payable_type = params[:payable_type]
    payable_id = params[:payable_id]

    case payable_type
    when 'Course'
      @payable_item = Course.find(payable_id)
    when 'Test'
      @payable_item = Test.find(payable_id)
    else
      redirect_to root_path, alert: 'Invalid payment item type.'
    end
  end
end
