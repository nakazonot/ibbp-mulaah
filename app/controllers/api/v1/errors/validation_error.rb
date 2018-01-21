class API::V1::Errors::ValidationError < API::V1::Errors::BaseException
  def initialize(message = 'Validation error')
    super(message: message, status: 422, code: API::V1::Errors::Types::VALIDATION_ERROR)
  end
end
