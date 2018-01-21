class API::V1::Errors::NotAuthorizedError < API::V1::Errors::BaseException
  def initialize(message = 'Don\'t have permission to access this resource')
    super(message: message, status: 403, code: API::V1::Errors::Types::NOT_AUTHORIZED_ERROR)
  end
end
