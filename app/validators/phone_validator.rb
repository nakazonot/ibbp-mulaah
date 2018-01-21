class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless format_valid?(value)
      record.errors[attribute] << (options[:message] || 'phone not valid')
    end
  end

  protected

  def format_valid?(value)
    !value.blank? && (5..16).include?(value.gsub(/[^0-9]/, '').length)
  end
end
