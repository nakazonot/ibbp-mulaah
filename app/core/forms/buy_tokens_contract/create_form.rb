class Forms::BuyTokensContract::CreateForm
  include ActiveModel::Model
  include Virtus.model

  attribute :user_id,     Integer
  attribute :coin_amount, BigDecimal
  attribute :currency,    String
  attribute :coin_price,  BigDecimal
  attribute :description, String
  attribute :add_bonus,   Boolean, default: true

  validates :coin_amount, presence: true, numericality: { greater_than: 0 }, coin_format: true
  validates :coin_price, presence: true, numericality: { greater_than: 0 }, currency_format: true
  validates :currency, presence: true, inclusion: Parameter.available_currencies.keys
  validates :user_id, presence: true

  def get_contract_data
    {
      'user_id'     => user_id,
      'currency'    => currency,
      'coin_amount' => coin_amount,
      'coin_price'  => coin_price
    }
  end

end