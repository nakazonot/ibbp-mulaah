class Users::ConfirmationsController < Devise::ConfirmationsController
  def create
    self.resource = User.find_or_initialize_with_errors([:email], resource_params, :not_found)

    if resource.errors.empty?
      if resource.is_oauth_sign_up
        resource.resend_oauth_email_confirmation
      else
        self.resource = resource_class.send_confirmation_instructions(resource_params)
        yield resource if block_given?
      end
    end

    if successfully_sent?(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end
end
