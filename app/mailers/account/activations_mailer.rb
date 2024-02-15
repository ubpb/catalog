class Account::ActivationsMailer < ApplicationMailer

  def onboarding_info(user)
    @user = user
    to_email = @user.ils_user.email
    return if to_email.blank?

    mail(to: to_email)
  end

end
