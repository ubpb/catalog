class UsersMailer < ApplicationMailer

  def activation_request(user)
    @user = user
    mail(to: @user.ils_user.email)
  end

  def account_activated(user)
    @user = user
    mail(to: @user.ils_user.email)
  end

  def registration_request(registration_request)
    @registration_request = registration_request
    mail(to: @registration_request.email)
  end

  def registration_created(registrations)
    @registration = registrations
    mail(to: @registration.email)
  end

  def password_reset_request(user)
    @user = user
    mail(to: @user.ils_user.email)
  end

end
