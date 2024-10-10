class ActivationsController < ApplicationController

  before_action { add_breadcrumb t("activations.breadcrumb"), activation_root_path }
  before_action :logout_current_user
  before_action :verify_activation_token_and_load_user, only: [:edit, :update]

  def show
    redirect_to request_activation_path(activation_params)
  end

  def new
    @form = ActivationRequestForm.new(
      ils_id: params[:id],
      activation_code: params[:code]
    )
  end

  def create
    @form = ActivationRequestForm.new(
      params.require(:activation).permit(:ils_id, :activation_code)
    )

    if @form.valid? && (ils_user = @form.ils_user).present?
      user = User.create_or_update_from_ils_user!(ils_user)
      user.create_activation_token!

      if @form.activation_code.present?
        redirect_to activation_path(user.activation_token)
      else
        UsersMailer.activation_request(user).deliver_later

        flash[:success] = t(".success", email: helpers.mask_email(ils_user.email))
        redirect_to root_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = ActivationForm.new
  end

  def update
    @form = ActivationForm.new(
      params.require(:activation).permit(:password, :password_confirmation, :terms_of_use)
    )

    if @form.valid?
      if activate_account(user: @user, password: @form.password)
        # Login user
        reset_session
        @user.reload_ils_user! # Make sure we have the latest data from ILS in the cache
        session[:current_user_id] = @user.id

        # Send info to user
        UsersMailer.account_activated(@user).deliver_later

        # Update UI
        flash[:success] = t(".success")
        redirect_to account_root_path
      else
        flash.now[:error] = t(".error")
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def logout_current_user
    if current_user
      reset_session
      session[:current_user_id] = nil

      flash[:info] = t("activations.common_messages.logout_info")
      redirect_to activation_root_path(activation_params) and return
    end

    true
  end

  def activation_params
    aparams = {}
    aparams[:id] = params[:id] if params[:id].present?
    aparams[:code] = params[:code] if params[:code].present?
    aparams
  end

  def verify_activation_token_and_load_user
    if (@token = params[:token]).blank?
      # Should not happen due to routes definition but we test anyway to be extra safe
      flash[:error] = t("activations.common_messages.no_token_error")
      redirect_to(activation_root_path) and return
    end

    @user = User.find_by(activation_token: @token)

    if @user.blank?
      flash[:error] = t("activations.common_messages.invalid_token_error")
      redirect_to(activation_root_path) and return
    elsif @user.activation_token_created_at + 6.hours <= Time.zone.now
      flash[:error] = t("activations.common_messages.expired_token_error")
      redirect_to(activation_root_path) and return
    end

    true
  end

  def activate_account(user:, password:)
    User.transaction do
      user.update!(
        activated_at: Time.zone.now,
        activation_token: nil,
        activation_token_created_at: nil,
        activation_code: nil
      )

      raise ActiveRecord::Rollback unless user.ils_user.activate_account
      raise ActiveRecord::Rollback unless Ils.set_user_password(user.ils_primary_id, password)

      true
    end
  end

end
