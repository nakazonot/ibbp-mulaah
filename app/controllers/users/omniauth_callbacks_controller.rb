class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include AuthenticatesWithOmniauth

  def google_oauth2
    authorize_with_oauth2(extract_info_from_callback(request.env['omniauth.auth']))
  end

  def facebook
    authorize_with_oauth2(extract_info_from_callback(request.env['omniauth.auth']))
  end

  private

  def authorize_with_oauth2(oauth_data)
    user_oauth = UsersOauthProvider.find_by(provider: oauth_data[:provider], uid: oauth_data[:uid])
    return nonexistent_oauth(oauth_data) if user_oauth.nil?
    return redirect_to(new_user_session_path, alert: t('errors.messages.user_not_exist')) if user_oauth.user.nil?

    implement_sign_up(user_oauth.user)
  end

  def nonexistent_oauth(oauth_data)
    set_oauth_session_data(oauth_data: oauth_data)

    return prompt_for_completion_oauth_registration(User.new) unless missing_oauth_fields.empty?

    user = User.find_by(email: oauth_data[:user_attributes][:email])
    return prompt_for_confirm_linking(user) if user.present?

    user_attributes = oauth_data[:user_attributes].merge(sign_up_ip: request.remote_ip)
    user            = User.create_from_omniauth(oauth_data[:provider], oauth_data[:uid], user_attributes)

    implement_sign_up(user) if user.persisted?
  end

  def extract_info_from_callback(oauth_data)
    return if oauth_data.blank?

    {
      uid:      oauth_data.uid,
      provider: oauth_data.provider,
      user_attributes: {
        name:  oauth_data.info[:name],
        email: oauth_data.info[:email]&.downcase
      }
    }
  end
end
