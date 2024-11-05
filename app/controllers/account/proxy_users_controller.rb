class Account::ProxyUsersController < Account::ApplicationController

  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.index"), account_proxy_users_path }
  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.new"), new_account_proxy_user_path }, only: [:new, :create]
  before_action -> { add_breadcrumb t("account.proxy_users.breadcrumb.edit"), edit_account_proxy_user_path }, only: [:edit, :update]

  before_action :ensure_enabled

  def index
    # Load the list of users the current has setup as proxies
    # and sync them with Alma.
    @proxy_users = current_user.proxy_users
    ProxyUserService.sync_proxy_users_with_alma(@proxy_users)

    # Load the list of users where the current user is a proxy for
    # and sync them with Alma.
    @proxy_for_users = ProxyUser.includes(:user).where(ils_primary_id: current_user.ils_primary_id)
    ProxyUserService.sync_proxy_users_with_alma(@proxy_for_users)

    # Make sure to reload the users to reflect the possible changes in the sync process above
    # as the sync might delete proxy users that do not exists in Alma anymore.
    @proxy_users.reload
    @proxy_for_users.reload
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
        name: ils_user.full_name_reversed
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
        if ProxyUserService.create_proxy_user_in_alma(
          proxy_user_id: @proxy_user.ils_primary_id,
          proxy_for_user_id: current_user.ils_primary_id
        )
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
        if ProxyUserService.delete_proxy_user_in_alma(
          proxy_user_id: @proxy_user.ils_primary_id,
          proxy_for_user_id: current_user.ils_primary_id
        )
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

  def ensure_enabled
    redirect_to account_root_path unless ProxyUserService.enabled?
    true
  end

  def proxy_user_params
    params.require(:proxy_user).permit(:ils_primary_id, :name, :note, :expired_at)
  end

  def ensure_proxy_is_not_self(user_id)
    if user_id&.downcase == current_user.ils_primary_id.downcase
      flash[:error] = t("account.proxy_users.cannot_proxy_self_error")
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

  def ensure_proxy_is_unique(user_id)
    if current_user.proxy_users.exists?(ils_primary_id: user_id)
      flash[:error] = t("account.proxy_users.already_exists_error", barcode: user_id)
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

end
