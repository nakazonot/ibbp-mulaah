class API::V1::Errors::Contracts::CreateError < API::V1::Errors::BaseException
  def initialize(message = 'Failed to create contract.')
    super(message: message, status: 409, code: API::V1::Errors::Types::CONTRACT_CREATE_ERROR)
  end
end
