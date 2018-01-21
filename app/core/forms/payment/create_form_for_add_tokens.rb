class Forms::Payment::CreateFormForAddTokens
  include ActiveModel::Model
  include Virtus.model

  attribute :user_id,     Integer
  attribute :coin_amount, BigDecimal
  attribute :description, String

  validates :coin_amount, presence: true, numericality: { greater_than: 0 }, coin_format: true
  validates :user_id, presence: true
  
  def get_payment_data
    params = Parameter.get_all
    {
      user_id:          user_id,
      iso_coin_amount:  coin_amount,
      amount_origin:    0,
      amount_buyer:     0,
      currency_origin:  params['coin.rate_currency'],
      currency_buyer:   params['coin.rate_currency'],
      description:      description,
      payment_type:     Payment::PAYMENT_TYPE_PURCHASE
    }
  end

end