class Services::OTP::Enable
  include Concerns::Log::Logger

  ERROR_INVALID_CODE    = 'error_invalid_code'.freeze
  ERROR_ALREADY_ENABLED = 'error_already_enabled'.freeze

  attr_reader :error, :backup_codes

  def initialize(user, code)
    @user = user
    @code = code
  end

  def call
    validate_code
    enable_and_generate_backup_codes

  rescue Services::OTP::EnableError => e
    @error = e.message
    log_error("user: #{@user.id}. #{e.message}")
    nil
  end

  private

  def validate_code
    raise Services::OTP::EnableError, ERROR_ALREADY_ENABLED if @user.two_factor_enabled?
    raise Services::OTP::EnableError, ERROR_INVALID_CODE unless @user.validate_and_consume_otp!(@code)
  end

  def enable_and_generate_backup_codes
    @backup_codes = @user.enable_two_factor!
  end
end
