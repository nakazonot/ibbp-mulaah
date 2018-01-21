module Concerns::Currency
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  def coin_round(amount)
    amount.to_f.to_d.round(coin_precision).to_f
  end

  def currency_round(amount, currency)
    amount.to_f.to_d.round(precision_by_currency(currency)).to_f
  end

  def coin_ceil(amount)
    amount.to_f.to_d.ceil(coin_precision).to_f
  end

  def currency_ceil(amount, currency)
    amount.to_f.to_d.ceil(precision_by_currency(currency)).to_f
  end

  def coin_floor(amount, precision = nil)
    precision ||= coin_precision
    amount.to_f.to_d.floor(precision).to_f
  end

  def currency_floor(amount, currency)
    amount.to_f.to_d.floor(precision_by_currency(currency)).to_f
  end

  def coin_rate_floor(amount)
    precision = Parameter.get_all['coin.currency_precision']
    precision = 6 if precision < 6

    amount.to_f.to_d.floor(precision).to_f
  end

  def percent_floor(amount)
    amount.to_f.to_d.floor(2).to_f
  end

  def ico_currency_floor(amount)
    currency_floor(amount, Parameter.get_all['coin.rate_currency'])
  end

  def ico_currency_ceil(amount)
    currency_ceil(amount, Parameter.get_all['coin.rate_currency'])
  end

  def equal_coins(coin1, coin2)
    coin_floor(coin1) == coin_floor(coin2)
  end

  def equal_currencies(currency1, currency2, currency)
    currency_floor(currency1, currency) == currency_floor(currency2, currency)
  end

  def coin_present?(amount)
    coin_floor(amount) >= (0.1 ** coin_precision).to_d
  end

  def currency_present?(amount, currency)
    currency_floor(amount, currency) >= (0.1 ** precision_by_currency(currency)).to_d
  end

  def coins_number_format(amount)
    number_with_precision(
      coin_floor(amount),
      precision: coin_precision,
      strip_insignificant_zeros: true,
      # delimiter: ","
    )
  end

  def currency_number_format(amount, currency)
    return usd_number_format(amount) if currency == ExchangeRate::DEFAULT_CURRENCY

    amount = 0 if amount.to_f.nan?
    number_with_precision(
      currency_floor(amount, currency),
      precision: precision_by_currency(currency),
      strip_insignificant_zeros: true,
      # delimiter: ","
    )
  end

  def usd_number_format(amount)
    amount = 0 if amount.to_f.nan?
    precision_default = 2
    precision = precision_by_currency(ExchangeRate::DEFAULT_CURRENCY)
    precision = precision_default if ((amount.to_d * (10 ** precision_default)) == (amount.to_d * (10 ** precision_default)).to_i)

    number_with_precision(
      currency_floor(amount, ExchangeRate::DEFAULT_CURRENCY),
      precision: precision,
      strip_insignificant_zeros: precision > precision_default,
      # delimiter: ","
    )
  end

  def ico_currency_number_format(amount)
    currency_number_format(amount, Parameter.get_all['coin.rate_currency'])
  end

  def percent_number_format(amount)
    number_with_precision(
      percent_floor(amount),
      precision: 2,
      strip_insignificant_zeros: true
    )
  end

  def original_number_format(amount)
    return 0 if amount.blank?

    number_with_precision(
      amount.to_d.to_f,
      precision: 20,
      strip_insignificant_zeros: true,
      # delimiter: ","
    )
  end

  def ico_currency_format(amount)
    parameters = Parameter.get_all
    "#{ico_currency_number_format(amount)} #{parameters['coin.rate_currency']}"
  end

  def currency_format(amount, currency)
    "#{currency_number_format(amount, currency)} #{currency}"
  end

  def percent_format(amount)
    "#{percent_number_format(amount)}%"
  end

  def precision_by_currency(currency)
    precisions = Parameter.precisions
    currency == ExchangeRate::DEFAULT_CURRENCY ? precisions[:usd] : precisions[:currency]
  end

  def coin_precision
    Parameter.precisions[:coin]
  end

end