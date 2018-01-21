class API::V1::Errors::BaseException < StandardError
  include ActiveModel::Serialization
  attr_reader :status, :code, :message

  def initialize(message: nil, status: nil, code: nil)
    @message = message
    @status  = status
    @code    = code
  end
end
