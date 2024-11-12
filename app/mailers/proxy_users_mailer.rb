class ProxyUsersMailer < ApplicationMailer

  def proxy_user_created(proxy_user:)
    @proxy_user = proxy_user

    to = @proxy_user.proxy_user.ils_user.email
    return if to.blank?

    mail(to: to)
  end

  def proxy_user_deleted(proxy_user_email:, proxy_user_name:, proxy_for_user_name: )
    @proxy_user_name = proxy_user_name
    @proxy_for_user_name = proxy_for_user_name

    return if proxy_user_email.blank?

    mail(to: proxy_user_email)
  end

  def proxy_user_expired_to_proxy_user(proxy_user_email:, proxy_user_name:, proxy_for_user_name:)
    @proxy_user_name = proxy_user_name
    @proxy_for_user_name = proxy_for_user_name

    return if proxy_user_email.blank?

    mail(to: proxy_user_email)
  end

  def proxy_user_expired_to_proxy_for_user(proxy_for_user_email:, proxy_user_name:, proxy_for_user_name:)
    @proxy_user_name = proxy_user_name
    @proxy_for_user_name = proxy_for_user_name

    return if proxy_for_user_email.blank?

    mail(to: proxy_for_user_email)
  end

end
