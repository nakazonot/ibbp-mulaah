module AuthenticatesWithOmniauth
  extend ActiveSupport::Concern

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    render 'devise/sessions/two_factor',
           layout: 'devise',
           locals: { resource: user, resource_name: :user }
  end

  def prompt_for_confirm_linking(user)
    set_oauth_session_data(user_id: user.id)
    render 'devise/omniauth/confirm_account_linking',
           layout: 'devise',
           locals: { resource: user, resource_name: :user }
  end

  def prompt_for_completion_oauth_registration(user)
    render 'devise/omniauth/completion_registration',
           layout: 'devise',
           locals: { resource: user, resource_name: :user, missing_fields: missing_oauth_fields }
  end

  def implement_sign_up(user)
    clear_omniauth_session_data
    return prompt_for_two_factor(user) if user.two_factor_enabled?

    flash[:notice] = t('devise.sessions.signed_in')
    sign_in_and_redirect(user, event: :authentication)
  end

  def set_oauth_session_data(user_id: nil, oauth_data: nil)
    session[:omniauth_user_id]   = user_id if user_id.present?
    session[:omniauth_user_data] = oauth_data if oauth_data.present?
  end

  def clear_omniauth_session_data
    session.delete(:otp_user_id) if session[:otp_user_id].present?
    session.delete(:omniauth_user_id) if session[:otp_user_id].present?
    session.delete(:omniauth_user_data) if session[:otp_user_id].present?
  end

  def missing_oauth_fields
    oauth_data = session[:omniauth_user_data]
    fields     = []

    if oauth_data.present?
      fields << :email if oauth_data[:user_attributes][:email].blank?
      fields << :name  if Parameter.require_user_name_input_on_sign_up? && oauth_data[:user_attributes][:name].blank?
    end

    fields
  end
end
