class PasswordResetsMailer < ApplicationMailer

  def notify_user(user)
    @user = user
    mail(to: @user.ils_user.email)
  end

end
