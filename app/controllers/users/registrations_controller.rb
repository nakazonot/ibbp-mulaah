class Users::RegistrationsController < Devise::RegistrationsController
  include Concerns::Log::Logger

  after_action :remove_referral_cookie,
               :logging,
               :send_event_registration_to_ga,
               :add_promo_token_address,
               :save_registration_complete_for_user,
               only: [:create]

  before_action :check_ico, only: [:new, :create]

  private

  def check_ico
    return redirect_to new_user_session_path unless can?(:ico_enabled, :ico)
    return redirect_to new_user_session_path, alert: I18n.t('registration.not_referral_follower_signup_error') unless can?(:do_sign_up, cookies)
  end

  def sign_up_params
    referral_id = cookies[:referral].present? ? User.find_by(referral_uuid: cookies[:referral])&.id : nil
    params.require(:user).permit(:email, :name, :password, :password_confirmation, :registration_agreement).merge(referral_id: referral_id, sign_up_ip: request.remote_ip)
  end

  def logging
    return if resource.new_record?
    msg   = "User ##{resource.id} registered now"
    msg  += " using referral link of user ##{resource.referral_id}" if resource.referral_id.present?
    log_info(msg)
  end

  def remove_referral_cookie
    return if resource.new_record?
    cookies.delete(:referral, domain: get_top_domain)
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def save_registration_complete_for_user
    return if resource.new_record?

    cookies[:registration_complete] = {
      value: resource.id,
      expires: 5.minutes.from_now
    }
  end

  def send_event_registration_to_ga
    return if resource.new_record?
    update_ga_client_id(resource)

    SendEventRegistrationNewJob.perform_later(resource.id)
  end

  def add_promo_token_address
    return if resource.new_record? || !Promocode.promo_token_enabled?
    Services::PaymentAddress::PromoTokensAddressGetter.new(user: resource).call
  end

  def omniauth_sign_up_params
    params.require(:user).permit(:email, :name)
  end
end
