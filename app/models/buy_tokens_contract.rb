class BuyTokensContract < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :payment, optional: true

  scope :by_user,     ->(user_id)  { where(user_id: user_id) }
  scope :send_to_gtm, ->           { where(send_transaction_to_gtm: true) }

  before_create :generate_uuid

  def generate_uuid
    self.assign_attributes(uuid: SecureRandom.uuid)
  end
end
