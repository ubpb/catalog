class FeedbacksMailer < ApplicationMailer
  before_action { @feedback = Feedback.new(params[:feedback]) }

  def notify_ub
    mail(to: "ortsleihe@ub.uni-paderborn.de", subject: "[UB-Feedback][#{@feedback.type}] ")
  end

  def notify_user
    mail(to: @feedback.email, subject: "[UB Paderborn] Ihr Feedback")
  end

end
