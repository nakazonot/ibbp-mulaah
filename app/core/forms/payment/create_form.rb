class Forms::Payment::CreateForm
  include ActiveModel::Model
  include Virtus.model

  attribute :user_id,     Integer
  attribute :amount,      BigDecimal
  attribute :currency,    String
  attribute :description, String
  attribute :add_bonus,   Boolean, default: true

  validates :amount, presence: true, numericality: { greater_than: 0 }, currency_format: true
  validates :currency, presence: true, inclusion: Parameter.available_currencies.keys
  validates :user_id, presence: true

  def get_payment_data
    {
      user:           User.find(user_id),
      currency:       currency,
      amount:         amount,
      description:    description.present? ? description : nil,
      disable_bonus:  !add_bonus
    }
  end

end