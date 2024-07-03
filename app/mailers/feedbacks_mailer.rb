class FeedbacksMailer < ApplicationMailer
  before_action { @feedback = Feedback.new(params[:feedback]) }

  ENABLED = Config[:feedback, :enabled, default: false]

  def notify_ub
    if ENABLED
      default_ubmail_config = Config[:feedback, :types, :default, :mail, :ub]
      feedback_type_config = Config[:feedback, :types, @feedback.type.to_sym, :mail, :ub, default: {}]

      merged_config = default_ubmail_config.merge(feedback_type_config)

      mail(from: merged_config[:from], to: merged_config[:to], subject: merged_config[:subject], template_name: merged_config[:template_name])
    end
  end

  def notify_user
    if ENABLED
      default_usermail_config = Config[:feedback, :types, :default, :mail, :user]
      feedback_type_config = Config[:feedback, :types, @feedback.type.to_sym, :mail, :user, default: {}]

      merged_config = default_usermail_config.merge(feedback_type_config)

      mail(from: merged_config[:from], to: @feedback.email, subject: merged_config[:subject], template_name: merged_config[:template_name])
    end
  end
end
