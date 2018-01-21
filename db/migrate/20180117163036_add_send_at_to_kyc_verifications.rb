class AddSendAtToKycVerifications < ActiveRecord::Migration[5.1]
  def change
    add_column :kyc_verifications, :sent_at, :datetime
    KycVerification.all.update_all('sent_at = created_at')
  end
end
