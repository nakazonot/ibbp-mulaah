class Services::IcosId::KycVerificationNotify
  include Concerns::Log::Logger

  ERROR_USER_NOT_EXIST                  = 'error_user_not_exist'.freeze
  ERROR_USER_KYC_VERIFICATION_NOT_EXIST = 'error_user_kyc_verification_not_exist'.freeze

  def initialize(params)
    @params = params.deep_dup
  end

  def call
    return unless ['approved', 'disapproved'].include?(@params['Status'])

    find_kyc_verification
    return if @kyc_verification.status == KycStatusType::APPROVED

    if @params['Status'] == 'approved'
      @kyc_verification.update_columns(
        status:      KycStatusType::APPROVED,
        verified_at: @params['VerifiedAt'].to_time
      )
    elsif @params['Status'] == 'disapproved'
      @kyc_verification.update_columns(
        status:      KycStatusType::REJECTED,
        deny_reason: @params['Reason']
      )
    end
  rescue Services::IcosId::KycVerificationNotifyError => e
    @error = e.message
    log_error("ICOS ID Verify Notification: email: #{@params['Email']}, error: #{e.message}")
    nil
  end

  private

  def find_kyc_verification
    @user = User.find_by_email(@params['Email'].downcase)
    raise Services::IcosId::KycVerificationNotifyError, ERROR_USER_NOT_EXIST if @user.blank?
    @kyc_verification = KycVerification.by_user(@user.id).first
    raise Services::IcosId::KycVerificationNotifyError, ERROR_USER_KYC_VERIFICATION_NOT_EXIST if @kyc_verification.blank?
  end

end