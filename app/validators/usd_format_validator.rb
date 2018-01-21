class UsdFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.to_f == currency_floor(value, ExchangeRate::DEFAULT_CURRENCY)
      record.errors[attribute] << (options[:message] || 'Too many decimal places')
    end
  end

end
