class Account::ProxyUsersController < Account::ApplicationController

  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.index"), account_proxy_users_path }
  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.new"), new_account_proxy_user_path }, only: [:new, :create]
  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.edit"), edit_account_proxy_user_path }, only: [:edit, :update]

  def index
    @proxy_users = current_user.proxy_users
  end

  def new
    if params[:barcode].present?
      ils_user = Ils.get_user(params[:barcode])

      unless ils_user
        flash[:error] = t(".lookup.no_user_found_error", barcode: params[:barcode])
        redirect_to new_account_proxy_user_path and return
      end

      ensure_proxy_is_not_self(ils_user.id) or return
      ensure_proxy_is_unique(ils_user.id) or return

      @proxy_user = current_user.proxy_users.build(
        ils_primary_id: ils_user.id,
        name: ils_user.full_name
      )
    else
      @proxy_user = current_user.proxy_users.build
    end
  end

  def create
    ProxyUser.transaction do
      @proxy_user = current_user.proxy_users.build(proxy_user_params)

      ensure_proxy_is_not_self(@proxy_user.ils_primary_id) or return
      ensure_proxy_is_unique(@proxy_user.ils_primary_id) or return

      if @proxy_user.save
        if create_proxy_user_in_alma(@proxy_user)
          flash[:success] = t(".success")
          redirect_to account_proxy_users_path
        else
          flash[:error] = t(".error")
          redirect_to account_proxy_users_path
          raise ActiveRecord::Rollback
        end
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @proxy_user = current_user.proxy_users.find(params[:id])
  end

  def update
    @proxy_user = current_user.proxy_users.find(params[:id])

    if @proxy_user.update(proxy_user_params)
      flash[:success] = t(".success")
      redirect_to account_proxy_users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ProxyUser.transaction do
      @proxy_user = current_user.proxy_users.find(params[:id])

      if @proxy_user.destroy
        if delete_proxy_user_in_alma(@proxy_user)
          flash[:success] = t(".success")
          redirect_to account_proxy_users_path
        else
          flash[:error] = t(".error")
          redirect_to account_proxy_users_path
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  private

  def proxy_user_params
    params.require(:proxy_user).permit(:ils_primary_id, :name, :note, :expired_at)
  end

  def create_proxy_user_in_alma(proxy_user)
    user_id = proxy_user.ils_primary_id
    user_details = get_user_details_from_alma(user_id)
    return false unless user_details

    # Get the existing proxies, or initialize an empty array
    # in case there are no proxies yet
    proxies = user_details["proxy_for_user"] ||= []

    # Check if the proxy user already exists in Alma. This can happen if the
    # proxy user was created in Alma directly
    return true if proxies.any? { |p| p["primary_id"].downcase == current_user.ils_primary_id.downcase }

    # Add the proxy user for the current user
    proxies << {
      primary_id: current_user.ils_primary_id
    }
    user_details["proxy_for_user"] = proxies

    # Update the user in Alma
    update_user_details_in_alma(user_id, user_details)
  end

  def delete_proxy_user_in_alma(proxy_user)
    user_id = proxy_user.ils_primary_id
    user_details = get_user_details_from_alma(user_id)
    return false unless user_details

    # Get the existing proxies, or initialize an empty array
    # in case there are no proxies yet
    proxies = user_details["proxy_for_user"] ||= []

    # Check if the proxy user exists in Alma. This can happen if the
    # proxy user was deleted in Alma directly
    return true if proxies.none? { |p| p["primary_id"].downcase == current_user.ils_primary_id.downcase }

    # Remove the proxy user for the current user
    user_details["proxy_for_user"] = proxies.reject do |p|
      p["primary_id"].downcase == current_user.ils_primary_id.downcase
    end

    # Update the user in Alma
    update_user_details_in_alma(user_id, user_details)
  end

  # Note: We use the Alma API directly in #get_user_details_from_alma and
  # #update_user_details_in_alma, rather than the Ils adapter. This
  # creates a direct dependecy on the Alma API. This is not ideal, but the
  # the proxy user feature is an Alma specific feature anyway, so we skip the
  # abstraction for now.

  def get_user_details_from_alma(user_id)
    Ils.adapter.api.get("users/#{user_id}")
  rescue AlmaApi::Error
    nil
  end

  def update_user_details_in_alma(user_id, user_details)
    Ils.adapter.api.put("users/#{user_id}", body: user_details.to_json)
    true
  rescue AlmaApi::Error => e
    Rails.logger.error(["Error updating user in Alma [#{e.code}]: #{e.message}", *e.backtrace].join($/))
    false
  end

  def ensure_proxy_is_not_self(user_id)
    if user_id&.downcase == current_user.ils_primary_id.downcase
      flash[:error] = t(".cannot_proxy_self_error")
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

  def ensure_proxy_is_unique(user_id)
    if current_user.proxy_users.exists?(ils_primary_id: user_id)
      flash[:error] = t(".already_exists_error", barcode: user_id)
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

end
