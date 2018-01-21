class Services::OTP::Disable
  include Concerns::Log::Logger

  ERROR_PASSWORD_INVALID = 'error_password_invalid'.freeze
  ERROR_OTP_NOT_ENABLED  = 'error_otp_not_enabled'.freeze

  attr_reader :error

  def initialize(user, password)
    @user     = user
    @password = password
  end

  def call
    validate_password
    disable_otp

  rescue Services::OTP::DisableError => e
    @error = e.message
    log_error("user: #{@user.id}. #{e.message}")
    nil
  end

  private

  def validate_password
    raise Services::OTP::DisableError, ERROR_OTP_NOT_ENABLED unless @user.two_factor_enabled?
    raise Services::OTP::DisableError, ERROR_PASSWORD_INVALID unless @user.valid_password?(@password)
  end

  def disable_otp
    @user.disable_two_factor!
  end
end
