class Services::OTP::RegenerateBackupCodes
  include Concerns::Log::Logger

  ERROR_PASSWORD_INVALID  = 'error_password_invalid'
  ERROR_OTP_REQUIRED      = 'error_otp_required'

  attr_reader :codes, :error

  def initialize(user, password)
    @user     = user
    @password = password
  end

  def call
    validate_password
    check_otp_state
    regenerate_codes

  rescue Services::OTP::RegenerateBackupCodesError => e
    @error = e.message
    log_error("user: #{@user.id}. #{e.message}")
    nil
  end

  private

  def validate_password
    raise Services::OTP::RegenerateBackupCodesError, ERROR_PASSWORD_INVALID unless @user.valid_password?(@password)
  end

  def check_otp_state
    raise Services::OTP::RegenerateBackupCodesError, ERROR_OTP_REQUIRED unless @user.two_factor_enabled?
  end

  def regenerate_codes
    @codes = @user.create_otp_backup_codes!
  end
end
