module AuthenticatesWithTwoFactor
  extend ActiveSupport::Concern

  included do
    # This action comes from DeviseController, but because we call `sign_in`
    # manually, not skipping this action would cause a "You are already signed
    # in." error message to be shown upon successful login.
    skip_before_action :require_no_authentication, only: [:create]
  end

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    render 'devise/sessions/two_factor'
  end

  def locked_user_redirect
    session.delete(:otp_user_id) if session[:otp_user_id].present?
    redirect_to new_user_session_path, alert: 'Your account has been locked'
  end

  def authenticate_with_two_factor
    user = self.resource = find_user
    return locked_user_redirect if user.access_locked?

    if user_params[:otp_attempt].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(user)
    elsif user && user.valid_password?(user_params[:password])
      prompt_for_two_factor(user)
    end
  end

  private

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      session.delete(:otp_user_id)
      remember_me(user) if user_params[:remember_me] == '1'
      sign_in(user)
    else
      user.increment_failed_attempts!
      flash.now[:alert] = 'Invalid two-factor code'
      prompt_for_two_factor(user)
    end
  end
end