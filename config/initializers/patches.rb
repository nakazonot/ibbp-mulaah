class ActionMailer::DeliveryJob
  queue_as :ibp_mailer_queue
end

Rails.application.config.to_prepare do
  Devise::Mailer.class_eval do
    def reset_password_instructions_register_from_admin(record, token, opts={})
      @token = token

      devise_mail(record, :reset_password_instructions_register_from_admin, opts)
    end

    def confirmation_notification_from_api(record, token, opts={})
      @confirmation_uri = opts.delete(:confirmation_uri)
      @referral_uri     = opts.delete(:referral_uri)
      @token            = token

      devise_mail(record, :confirmation_instructions, opts)
    end

    def reset_password_instructions_from_api(record, token, opts={})
      @edit_password_uri = opts.delete(:edit_password_uri)
      @token             = token

      devise_mail(record, :reset_password_instructions, opts)
    end

    def unlock_instructions_from_api(record, token, opts={})
      @unlock_uri = opts.delete(:unlock_uri)
      @token      = token

      devise_mail(record, :unlock_instructions, opts)
    end

    def confirmation_oauth_email_notification(record, token, opts={})
      @token = token

      devise_mail(record, :confirmation_oauth_email_instructions, opts)
    end
  end
end
