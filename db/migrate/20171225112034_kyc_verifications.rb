class KycVerifications < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE kyc_gender AS ENUM ('male', 'female');
    SQL

    execute <<-SQL
      CREATE TYPE kyc_status AS ENUM ('approved', 'in_progress', 'rejected', 'draft');
    SQL

    create_table :kyc_verifications do |t|
      t.references :user, index: true, foreign_key: true
      t.string     :first_name
      t.string     :middle_name
      t.string     :last_name
      t.string     :phone
      t.json       :address
      t.column     :gender, :kyc_gender
      t.string     :state
      t.string     :citizenship
      t.string     :city
      t.string     :country_code
      t.column     :status, :kyc_status, default: 'draft'
      t.string     :deny_reason
      t.date       :dob
      t.datetime   :verified_at

      t.timestamps
    end
  end
end
