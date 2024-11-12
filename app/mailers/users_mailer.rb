class UsersMailer < ApplicationMailer

  def activation_request(user)
    @user = user

    to = @user.ils_user.email
    return if to.blank?

    mail(to: to)
  end

  def account_activated(user)
    @user = user

    to = @user.ils_user.email
    return if to.blank?

    mail(to: to)
  end

  def registration_request(registration_request)
    @registration_request = registration_request

    to = @registration_request.email
    return if to.blank?

    mail(to: to)
  end

  def registration_created(registrations)
    @registration = registrations

    to = @registration.email
    return if to.blank?

    mail(to: to)
  end

  def password_reset_request(user)
    @user = user

    to = @user.ils_user.email
    return if to.blank?

    mail(to: to)
  end

end
