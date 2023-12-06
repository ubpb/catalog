class FeedbacksController < ApplicationController

  def new
    @feedback = Feedback.new

    if params[:record_id]  && params[:record_scope]
      record = SearchEngine[params[:record_scope]].get_record(params[:record_id])

      @feedback.record_scope = params[:record_scope]
      @feedback.record_id = record.id
      @feedback.record_title = record.title
    end

    if current_user.present?
      @feedback.firstname = current_user.first_name.presence || ""
      @feedback.lastname = current_user.last_name.presence || ""
      @feedback.email = current_user.email.presence
    end

    if turbo_frame_request?
      render "show-modal"
    else
      render :new
    end
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.valid?
      @feedback.user_id = current_user&.ils_primary_id.presence || "anonymous"

      FeedbacksMailer.with(feedback: @feedback.as_json).notify_ub.deliver_later
      FeedbacksMailer.with(feedback: @feedback.as_json).notify_user.deliver_later

      if turbo_frame_request?
        render "success-modal"
      else
        flash[:success] = t(".success")
        redirect_to root_path
      end
    else
      if turbo_frame_request?
        render "show-modal", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

private

  def feedback_params
    params.require(:feedback).permit(
      :type,
      :record_scope,
      :record_id,
      :record_title,
      :message,
      :firstname,
      :lastname,
      :email
    )
  end

end
