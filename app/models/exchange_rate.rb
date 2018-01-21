class ExchangeRate < ApplicationRecord
  DEFAULT_CURRENCY           = 'USD'

  scope :by_currency, ->(currency) { where(from: currency) }

  def self.get_rate(cur1, cur2)
    cur1_to_btc = find_by(from: cur1, to: 'BTC')
    cur2_to_btc = find_by(from: cur2, to: 'BTC')
    cur1_to_btc.present? && cur2_to_btc.present? ? cur1_to_btc.rate * (1 / cur2_to_btc.rate) : nil
  end

  def self.to_btc_rate(from)
    Rails.cache.fetch("exchange_rate_to_btc_from_#{from}", expires_in: 30.seconds) do
      rate = find_by(from: from, to: 'BTC')
      rate.present? ? rate.rate : nil
    end
  end

  def self.add_rate(from, to, rate, system)
    exrate                = find_or_initialize_by(from: from, to: to)
    exrate.rate           = rate
    exrate.payment_system = system
    exrate.save!
  end

  def self.sync_currencies
    coins_to_btc = Services::PaymentSystem::MainWrapper.new.get_rates
    coins_to_btc.each do |currency_symbol, currency|
      add_rate(currency[:from], 'BTC', currency[:rate].round(10), currency[:payment_system])
    end
    Rails.cache.delete_matched("exchange_rate*")
  end
end