class API::V1::Errors::ICOClosedError < API::V1::Errors::BaseException
  def initialize(message = 'ICO closed.')
    super(message: message, status: 403, code: API::V1::Errors::Types::ICO_CLOSED_ERROR)
  end
end
