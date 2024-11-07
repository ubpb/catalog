class ProxyUserService < ApplicationService

  ENABLED = Config[:proxy_user, :enabled, default: false]

  class Error < StandardError; end
  class DisabledError < Error; end

  class << self

    delegate :create_proxy_user_in_alma, to: :new
    delegate :delete_proxy_user_in_alma, to: :new
    delegate :sync_proxy_users_with_alma, to: :new
    delegate :sync_proxy_for_users_with_alma, to: :new

    def enabled?
      ENABLED
    end

  end

  def initialize # rubocop:disable Lint/MissingSuper
    raise DisabledError unless self.class.enabled?
  end

  def create_proxy_user_in_alma(proxy_user_ils_primary_id:, proxy_for_user_ils_primary_id:)
    proxy_user_details = get_user_details_from_alma(proxy_user_ils_primary_id)
    return false unless proxy_user_details

    # Get the existing proxies, or initialize an empty array
    # in case there are no proxies yet
    proxy_for_users = proxy_user_details["proxy_for_user"] ||= []

    # Check if the proxy user already exists in Alma. This can happen if the
    # proxy user was created in Alma directly
    return true if proxy_for_users.any? { |p| p["primary_id"].downcase == proxy_for_user_ils_primary_id.downcase }

    # Add the proxy user for the current user
    proxy_for_users << {
      primary_id: proxy_for_user_ils_primary_id
    }
    proxy_user_details["proxy_for_user"] = proxy_for_users

    # Update the user in Alma
    update_user_details_in_alma(proxy_user_ils_primary_id, proxy_user_details)
  end

  def delete_proxy_user_in_alma(proxy_user_ils_primary_id:, proxy_for_user_ils_primary_id:)
    proxy_user_details = get_user_details_from_alma(proxy_user_ils_primary_id)
    return false unless proxy_user_details

    # Get the existing proxies, or initialize an empty array
    # in case there are no proxies yet
    proxy_for_users = proxy_user_details["proxy_for_user"] ||= []

    # Check if the proxy user exists in Alma. This can happen if the
    # proxy user was deleted in Alma directly
    return true if proxy_for_users.none? { |p| p["primary_id"].downcase == proxy_for_user_ils_primary_id.downcase }

    # Remove the proxy user for the current user
    proxy_user_details["proxy_for_user"] = proxy_for_users.reject do |p|
      p["primary_id"].downcase == proxy_for_user_ils_primary_id.downcase
    end

    # Update the user in Alma
    update_user_details_in_alma(proxy_user_ils_primary_id, proxy_user_details)
  end

  # This syncs the given proxy users from our database with Alma. Our database acts as the master.
  def sync_proxy_users_with_alma(proxy_users)
    proxy_users.each do |proxy_user|
      # Load the proxy user and the user the proxy belongs to from Alma to see
      # if these users still exists
      ils_proxy_user = Ils.get_user(proxy_user.proxy_user.ils_primary_id)
      ils_proxy_for_user = Ils.get_user(proxy_user.user.ils_primary_id)

      if ils_proxy_user.present? && ils_proxy_for_user.present?
        # Both users exist in Alma. Reload the connected ILS users to reflect
        # possible changes in Alma.
        # DISABLED FOR NOW, AS THIS IS NOT NEEDED IN PRACTICE.
        # proxy_user.user.reload_ils_user!
        # proxy_user.proxy_user.reload_ils_user!

        # Recreate the proxy relationship in Alma in case it has been delete.
        # This method skips the creation if the relationship already exists.
        create_proxy_user_in_alma(
          proxy_user_ils_primary_id: proxy_user.proxy_user.ils_primary_id,
          proxy_for_user_ils_primary_id: proxy_user.user.ils_primary_id
        )
      else
        # One or both of the users do not exist in Alma anymore,
        # delete the proxy user instance.
        proxy_user.destroy
      end
    end
  end

  private

  def get_user_details_from_alma(user_id)
    Ils.adapter.api.get("users/#{user_id}")
  rescue AlmaApi::LogicalError
    nil
  end

  def update_user_details_in_alma(user_id, user_details)
    Ils.adapter.api.put("users/#{user_id}", body: user_details.to_json)
    true
  rescue AlmaApi::LogicalError => e
    Rails.logger.error(
      ["[ProxyUserService] Error updating user in Alma [#{e.code}]: #{e.message}", *e.backtrace].join($INPUT_RECORD_SEPARATOR)
    )

    false
  end

end
