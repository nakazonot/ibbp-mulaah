class PaymentAddress < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  scope :by_user,             ->(user_id)  { where(user_id: user_id) }
  scope :not_user,            ->           { where(user_id: nil) }
  scope :by_currency,         ->(currency) { where(currency: currency) }
  scope :by_dest_tag,         ->(dest_tag) { where(dest_tag: dest_tag) unless dest_tag.blank? }
  scope :by_payment_system,   ->(p_system) { where(payment_system: p_system) }
  scope :by_address_type,     ->(a_type)   { where(address_type: a_type) }

  def self.statistics
    statistics = {}
    query = select('currency, payment_system, address_type, COUNT(id) FILTER (WHERE user_id IS NOT NULL) AS used, COUNT(id) FILTER (WHERE user_id IS NULL) as unused')
      .group('currency, payment_system, address_type')

    query.each do |model|
      statistics[model.address_type] = {} unless statistics[model.address_type].present?
      statistics[model.address_type][model.payment_system] = {} unless statistics[model.address_type][model.payment_system].present?
      statistics[model.address_type][model.payment_system][model.currency] = { used: model.used, unused: model.unused }
    end
    statistics
  end

  def self.promo_token_adress_by_user(user_id)
    self.by_user(user_id).by_address_type(PaymentAddressType::PROMO_TOKENS).first
  end

  def self.deposit_addresses_by_user(user_id)
    addresses = {}
    Parameter.available_currencies.except('USD').each do |currency_code, currency_information|
      addresses[currency_code] =  PaymentAddress.by_user(user_id)
                                    .by_payment_system(currency_information['payment_system'])
                                    .by_address_type(PaymentAddressType::DEPOSIT)
                                    .find_by(currency: currency_code)
    end

    addresses
  end
end
