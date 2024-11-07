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
    @proxy_for_users = ProxyUser.includes(:user, :proxy_user).where(proxy_user: current_user)
    ProxyUserService.sync_proxy_users_with_alma(@proxy_for_users)

    # Make sure to reload the users to reflect the possible changes in the sync process above
    # as the sync might delete proxy users that do not exists in Alma anymore.
    @proxy_users.reload
    @proxy_for_users.reload
  end

  def new
    return if params[:barcode].blank?

    # User has filled out the lookup form. Lets check against Alma
    # if we can find a user with the given user ID / barcode.
    barcode = params[:barcode].strip
    ils_user = Ils.get_user(barcode)

    # If we cannot find a user in Alma, we show an error message
    # and return
    unless ils_user
      flash[:error] = t(".lookup.no_user_found_error", barcode: barcode)
      redirect_to new_account_proxy_user_path and return
    end

    # Finally we can build the proxy user object
    @proxy_user = current_user.proxy_users.build(
      # Attributes used by the form
      ils_primary_id: ils_user.id,
      name: ils_user.full_name_reversed
    )
  end

  def create
    ProxyUser.transaction do
      # Build the proxy user object based on the submitted form data
      @proxy_user = current_user.proxy_users.build(proxy_user_params)

      # Fetch the proxy user from Alma to make sure it exists.
      proxy_ils_user = Ils.get_user(@proxy_user.ils_primary_id)
      unless proxy_ils_user
        flash[:error] = t(".error")
        redirect_to account_proxy_users_path and return
      end

      # Make sure the proxy user has a local user record.
      proxy_db_user = User.create_or_update_from_ils_user!(proxy_ils_user)
      # Assign the local user that represents the proxy user to the proxy user object.
      @proxy_user.proxy_user = proxy_db_user

      # Run some checks.
      ensure_proxy_is_not_self(proxy_db_user) or return
      ensure_proxy_is_unique(proxy_db_user) or return

      # Save the proxy user and create the proxy relationship in Alma.
      if @proxy_user.save
        if ProxyUserService.create_proxy_user_in_alma(
          proxy_user_ils_primary_id: @proxy_user.proxy_user.ils_primary_id,
          proxy_for_user_ils_primary_id: @proxy_user.user.ils_primary_id
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
    @proxy_user.name = @proxy_user.proxy_user.ils_user.full_name_reversed
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
          proxy_user_ils_primary_id: @proxy_user.proxy_user.ils_primary_id,
          proxy_for_user_ils_primary_id: @proxy_user.user.ils_primary_id
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
    params.require(:proxy_user).permit(
      :ils_primary_id, :name, :note, :expired_at
    )
  end

  def ensure_proxy_is_not_self(proxy_db_user)
    if proxy_db_user == current_user
      flash[:error] = t("account.proxy_users.cannot_proxy_self_error")
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

  def ensure_proxy_is_unique(proxy_db_user)
    if current_user.proxy_users.all.any? { |pu| pu.proxy_user.ils_primary_id == proxy_db_user.ils_primary_id }
      flash[:error] = t("account.proxy_users.already_exists_error")
      redirect_to new_account_proxy_user_path and return
    end

    true
  end

end
