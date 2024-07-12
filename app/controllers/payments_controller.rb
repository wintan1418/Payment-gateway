class PaymentsController < ApplicationController
  before_action :authenticate_user!
  
  def new
  end

  def create
    @amount = params[:amount].to_i  # Convert amount to integer

    # Create a new Stripe customer with a new token each time
    customer = Stripe::Customer.create({
      email: current_user.email,  # Assuming you want to use the current user's email for Stripe
      source: params[:stripeToken],  # Use the new token from the form
    })

    # Create a charge with the customer ID
    _charge = Stripe::Charge.create({
      customer: customer.id,
      amount: @amount,
      description: 'Rails Stripe customer',
      currency: 'usd',
    })

    # Send SMS notification if phone number is present
    if params[:phone_number].present?
      client = Twilio::REST::Client.new(Rails.application.credentials.dig(:twilio, :account_sid), Rails.application.credentials.dig(:twilio, :auth_token))

      # Example of sending SMS
      client.messages.create(
        from: Rails.application.credentials.dig(:twilio, :phone_number),
        to: current_user.phone_number,
        body: "Your payment of $#{@amount / 100.0} was successful."
      )
      Rails.logger.info "SMS sent to #{params[:phone_number]} with message SID: #{message.sid}"
    end

    # Send email notification
    UserMailer.payment_confirmation(current_user, @amount).deliver_now
    redirect_to payment_success_path, notice: 'Payment successful!'

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_payment_path
  rescue Twilio::REST::RestError => e
    flash[:error] = "SMS notification failed: #{e.message}"
    redirect_to new_payment_path
  end
end
