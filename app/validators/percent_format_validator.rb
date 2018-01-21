class PercentFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.to_f == percent_floor(value)
      record.errors[attribute] << (options[:message] || 'Too many decimal places')
    end
  end

end
