class AddIdentificationNumberToKyc < ActiveRecord::Migration[5.1]
  def change
    add_column :kyc_verifications, :document_number, :string
  end
end
