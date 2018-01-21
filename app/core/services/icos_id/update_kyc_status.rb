class Services::IcosId::UpdateKycStatus
  include Concerns::Log::Logger

  ERROR_GETTING_ICOS_ID_ACCOUNT      = 'error_getting_icos_id_account'.freeze

  attr_reader :error

  def initialize(kyc_verification)
    @kyc_verification = kyc_verification
    @user = kyc_verification.user
  end

  def call
    update_kyc_status

  rescue Services::IcosId::UpdateKycStatusError => e
    @error = e.message
    log_error("ICOS ID. Error updating KYC status: #{@user.email}. #{@error}")
    nil
  end

  private

  def update_kyc_status
    icos_id_get_account = Services::IcosId::GetAccount.new(@user.email)
    icos_id_get_account.call

    if icos_id_get_account.error.present?
      raise Services::IcosId::UpdateKycStatusError, ERROR_GETTING_ICOS_ID_ACCOUNT
    end

    if icos_id_get_account.data[:kyc_status] == 'approved'
      @kyc_verification.update_columns(
        status: KycStatusType::APPROVED, 
        verified_at: icos_id_get_account.data[:kyc_at].to_time, 
      )
    elsif icos_id_get_account.data[:kyc_status] == 'disapproved'
      @kyc_verification.update_columns(
        status: KycStatusType::REJECTED, 
        deny_reason: icos_id_get_account.data[:kyc_reason]
      )
    end

  end
end
