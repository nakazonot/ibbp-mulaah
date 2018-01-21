class Forms::Payment::CreateFormForRefundTokens
  include ActiveModel::Model
  include Virtus.model

  attribute :user_id,     Integer
  attribute :coin_amount, BigDecimal
  attribute :description, String

  validates :coin_amount, presence: true, numericality: { greater_than: 0 }, coin_format: true
  validates :coin_amount, numericality: { 
    less_than_or_equal_to: ->(payment) { Payment.by_user(payment.user_id).user_total_amount_tokens },
    message: "User does not have enough tokens"
  }
  validates :user_id, presence: true
  
  def get_payment_data
    params = Parameter.get_all
    {
      user_id:          user_id,
      iso_coin_amount:  coin_amount,
      amount_origin:    0,
      amount_buyer:     0,
      description:      description,
      payment_type:     Payment::PAYMENT_TYPE_REFUND_TOKENS
    }
  end

end