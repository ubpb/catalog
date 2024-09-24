# Note: We use the Alma API directly in #get_user_details_from_alma and
# #update_user_details_in_alma, rather than go to the Ils adapter. This
# creates a direct dependecy on the Alma API. This is not ideal, but the
# the proxy user feature is an Alma specific feature anyway, so we skip the
# abstraction for now.
class ProxyUserService < ApplicationService

  ENABLED = Config[:proxy_user, :enabled, default: false]

  class Error < StandardError; end
  class DisabledError < Error; end

  class << self

    delegate :create_proxy_user_in_alma, to: :new
    delegate :delete_proxy_user_in_alma, to: :new

    def enabled?
      ENABLED
    end

  end

  def initialize # rubocop:disable Lint/MissingSuper
    raise DisabledError unless self.class.enabled?
  end

  def create_proxy_user_in_alma(proxy_user:, current_user:)
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

  def delete_proxy_user_in_alma(proxy_user:, current_user:)
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

  private

  def get_user_details_from_alma(user_id)
    Ils.adapter.api.get("users/#{user_id}")
  rescue AlmaApi::Error
    nil
  end

  def update_user_details_in_alma(user_id, user_details)
    Ils.adapter.api.put("users/#{user_id}", body: user_details.to_json)
    true
  rescue AlmaApi::Error => e
    Rails.logger.error(
      ["[ProxyUserService] Error updating user in Alma [#{e.code}]: #{e.message}", *e.backtrace].join($INPUT_RECORD_SEPARATOR)
    )

    false
  end

end
