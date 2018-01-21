class CurrencyFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.currency.present? && value.to_f != currency_floor(value, record.currency)
      record.errors[attribute] << (options[:message] || 'Too many decimal places')
    end
  end

end
