class Forms::Invoice::CreateForm
  include ActiveModel::Model
  include Virtus.model

  attr_accessor :assets

  attribute :email,           String
  attribute :full_name,       String
  attribute :country,         String
  attribute :state,           String
  attribute :postal_code,     String
  attribute :city,            String
  attribute :address,         String
  attribute :phone,           String
  attribute :bank,            String
  attribute :amount,          Float

  validates :full_name, presence: true
  validates :phone,     phone: { allow_blank: true, message: 'must contain 5 to 19 digits' }
  validates :amount,    presence: true, numericality: { greater_than_or_equal_to: Proc.new {Parameter.min_amount_for_transfer}, less_than_or_equal_to: Proc.new {Parameter.max_amount_for_transfer} }
  validates :amount,    usd_format: true
end
