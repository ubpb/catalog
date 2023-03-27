class RegistrationsMailer < ApplicationMailer

  def notify_user(registrations)
    @registration = registrations
    mail(to: @registration.email, subject: "[UB Paderborn] Ihre Registrierung")
  end

end
