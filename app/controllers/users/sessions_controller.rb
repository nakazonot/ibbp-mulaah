class Users::SessionsController < Devise::SessionsController
  include AuthenticatesWithTwoFactor

  protect_from_forgery prepend: true, with: :exception

  prepend_before_action :sign_in_with_two_factor, if: :two_factor_enabled?, only: [:create]
  prepend_before_action :block_from_oauth_users, only: :create

  private

  def block_from_oauth_users
    user = User.find_by(email: user_params[:email])
    if user.present? && user.is_oauth_sign_up && user.oauth_email_confirmed_at.nil?
      redirect_to new_user_session_path, alert: 'You can sign in only through social networks!'
    end
  end

  def sign_in_with_two_factor
    get_config_parameters
    create_body_id
    authenticate_with_two_factor
  end

  def user_params
    params.require(:user).permit(:email, :password, :remember_me, :otp_attempt, :device_response)
  end

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    elsif user_params[:email]
      User.find_by(email: user_params[:email]&.downcase)
    end
  end

  def two_factor_enabled?
    find_user.try(:two_factor_enabled?)
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) || user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end
end
