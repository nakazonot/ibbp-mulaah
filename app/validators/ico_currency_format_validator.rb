class IcoCurrencyFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
  	unless value.to_f == currency_floor(value, Parameter.get_all['coin.rate_currency'])
      record.errors[attribute] << (options[:message] || 'Too many decimal places')
    end
  end

end
