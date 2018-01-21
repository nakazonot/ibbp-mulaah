module API::V1::Helpers::UserAbility
  SKIP_AUTH_METHODS = {
    POST:   %w[
      /users/registrations
      /users/sessions
      /users/passwords
      /users/confirmations
    ],
    GET:    %w[
      /parameters
      /infos/system
      /infos/raised
      /translations
    ],
    PUT:    %w[
      /users/confirmations
      /users/passwords
      /users/unlocks
      /users/activations
    ],
    DELETE: %w[]
  }

  SKIP_AUTH_EXCEPTION = {
    GET:    %w[
      /infos/abilities
    ],
    POST:   %[],
    PUT:    %[],
    DELETE: %[]
  }

  def authorize_user!
    return if request_without_auth?
    @current_user = env['warden'].authenticate
    fail API::V1::Errors::Users::UnauthenticatedError if !skip_auth_exception? && @current_user.nil?
  end

  def authorized_user?
    return true if request_without_auth?
    @current_user.present?
  end

  def request_without_auth?
    SKIP_AUTH_METHODS[@env['REQUEST_METHOD'].to_sym].include?(@env['PATH_INFO'])
  end

  def current_user
    @current_user
  end

  def skip_auth_exception?
    SKIP_AUTH_EXCEPTION[@env['REQUEST_METHOD'].to_sym].include?(@env['PATH_INFO'])
  end
end
