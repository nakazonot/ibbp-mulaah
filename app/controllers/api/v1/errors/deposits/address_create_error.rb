class API::V1::Errors::Deposits::AddressCreateError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('payment_address.deposit.can_not_get_address'))
    super(message: message, status: 409, code: API::V1::Errors::Types::DEPOSIT_ADDRESS_CREATE_ERROR)
  end
end

