class API::V1::Errors::Contracts::AcceptError < API::V1::Errors::BaseException
  def initialize(message = 'Failed to accept contract.')
    super(message: message, status: 409, code: API::V1::Errors::Types::CONTRACT_ACCEPT_ERROR)
  end
end
