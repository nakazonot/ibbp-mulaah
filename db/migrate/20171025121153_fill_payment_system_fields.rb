class FillPaymentSystemFields < ActiveRecord::Migration[5.1]
  def change
    Payment.unscoped.by_type(Payment::PAYMENT_TYPE_BALANCE).not_system.where(created_by_user_id: nil, currency_buyer: 'USD').find_in_batches(batch_size: 50) do |payments|
      Payment.where(id: payments.map(&:id)).update_all(payment_system: 'invoiced')
    end

    Payment.unscoped.by_type(Payment::PAYMENT_TYPE_BALANCE).not_system.where(created_by_user_id: nil).where.not(currency_buyer: 'USD').find_in_batches(batch_size: 50) do |payments|
      Payment.where(id: payments.map(&:id)).update_all(payment_system: 'coin_payments')
    end

    PaymentAddress.unscoped.update_all(payment_system: 'coin_payments')
  end
end
