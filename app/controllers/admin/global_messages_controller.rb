class Admin::GlobalMessagesController < Admin::ApplicationController

  before_action -> { add_breadcrumb("Globale Nachricht", admin_global_message_path) }

  def show
    redirect_to edit_admin_global_message_path
  end

  def edit
    @global_message = Admin::GlobalMessage.first_or_initialize
  end

  def update
    @global_message = Admin::GlobalMessage.new(global_message_params)

    Admin::GlobalMessage.transaction do
      if Admin::GlobalMessage.destroy_all && @global_message.save
        flash[:success] = "Die globale Nachricht wurde erfolgreich aktualisiert."
        redirect_to admin_global_message_path
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def authorize!
    super
    raise NotAuthorizedError unless current_admin_user.can_access_admin_global_message?
  end

  def global_message_params
    params.require(:admin_global_message).permit(:active, :message, :style)
  end

end
