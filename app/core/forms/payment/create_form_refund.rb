class Forms::Payment::CreateFormRefund
  include ActiveModel::Model
  include Virtus.model

  attribute :user_id,         Integer
  attribute :amount,          BigDecimal
  attribute :currency,        String
  attribute :description,     String

  validates :currency, presence: true, inclusion: Parameter.available_currencies.keys
  validates :amount, presence: true, numericality: { greater_than: 0 }, currency_format: true
  validates :amount, numericality: { 
    less_than_or_equal_to: ->(payment) { Payment.balances_by_user_currency(User.find(payment.user_id), payment.currency) },
    message: "User does not have enough coins on the balance in selected currency"
  }, if: ->(payment) { payment.currency.present? }
  validates :user_id, presence: true

  def get_payment_data
    {
      user_id:         user_id,
      amount_buyer:    amount,
      amount_origin:   amount,
      currency_buyer:  currency,
      currency_origin: currency,
      description:     description,
      payment_type:    Payment::PAYMENT_TYPE_REFUND
    }
  end

end