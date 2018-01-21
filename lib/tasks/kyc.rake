namespace :kyc do
  desc "Update KYC info"
  task update_kyc_verification_status: :environment do
    abort 'KYC is not enabled' unless Parameter.kyc_verification_enabled?

    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task kyc:update_kyc_verification_status"

    kyc_verifications = KycVerification.required_sync
    kyc_verifications.find_each(batch_size: 100).each do |kyc_verification|
      Services::IcosId::UpdateKycStatus.new(kyc_verification).call
    end
    puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task kyc:update_kyc_verification_status"
  end
end
