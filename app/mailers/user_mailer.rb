class UserMailer < ApplicationMailer
  def payment_confirmation(user, amount)
    @user = user
    @amount = amount
    mail(to: @user.email, subject: 'Payment Confirmation')
  end
end
