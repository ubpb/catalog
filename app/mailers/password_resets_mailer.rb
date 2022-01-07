class PasswordResetsMailer < ApplicationMailer

  def notify_user(user)
    @user = user
    mail(to: @user.email, subject: "[UB Paderborn] Passwort zurücksetzen")
  end

end
