class Invoice < ApplicationRecord
  belongs_to :invoice_customer, optional: true
  belongs_to :payment, optional: true

  STATUS_CREATED = 'created'
  STATUS_PAID    = 'paid'
end
