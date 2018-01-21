class InvoiceCustomer < ApplicationRecord
  belongs_to :user, optional: true

  scope :by_user,           ->(user_id) { where(user_id: user_id) }
end
