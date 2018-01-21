class OmniauthController < ApplicationController
  include AuthenticatesWithOmniauth

  def completion_oauth_registration
    user = User.find_by(email: completion_registration_params[:email].downcase)
    return prompt_for_confirm_linking(user) if user.present?

    oauth_data      = session[:omniauth_user_data]
    user_attributes = {
      email:      completion_registration_params.fetch(:email, oauth_data[:user_attributes][:email]),
      name:       completion_registration_params.fetch(:name, oauth_data[:user_attributes][:name]),
      sign_up_ip: request.remote_ip
    }

    user = User.create_from_omniauth(
      oauth_data[:provider],
      oauth_data[:uid],
      user_attributes,
      need_send_confirmation: missing_oauth_fields.include?(:email)
    )
    return implement_sign_up(user) if user.persisted?

    prompt_for_completion_oauth_registration(user)
  end

  def confirm_account_linking
    return if session[:omniauth_user_id].blank? || session[:omniauth_user_data].blank?

    user = User.find(session[:omniauth_user_id])
    return handle_invalid_password(user) unless user.valid_password?(confirm_linking_params[:password])

    user.oauth_providers.find_or_create_by(
      provider: session[:omniauth_user_data][:provider],
      uid:      session[:omniauth_user_data][:uid]
    )

    implement_sign_up(user)
  end

  def confirmation_email
    user = User.confirm_oauth_email_by_token(params[:confirmation_oauth_email_token])
    if user.errors.present?
      flash[:error]  = user.errors.full_messages.first
    else
      flash[:notice] = t('devise.confirmations.confirmed')
    end

    redirect_to current_user.present? ? root_path : new_user_session_path
  end

  private

  def confirm_linking_params
    params.require(:user).permit(:password)
  end

  def completion_registration_params
    params.require(:user).permit(:email, :name)
  end

  def handle_invalid_password(user)
    user.errors.add(:current_password, :invalid)
    prompt_for_confirm_linking(user)
  end
end
