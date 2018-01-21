class EthWalletValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless is_address_valid?(value)
      record.errors[attribute] << (options[:message] || 'format is invalid')
    end
  end

  protected

  def is_address_valid?(value)
    Services::Eth::AddressValidator.new(value).call
  end
end
