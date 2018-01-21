class API::V1::OTP < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::OTP

  resource :otp do
    desc 'Generating a secret key for 2FA.'
    post :secrets do
      issuer   = headers.fetch('Referer', 'bookbuilding')
      enabling = Services::OTP::GenerateSecret.new(current_user, issuer, need_generate_qr: false).call

      present(enabling, with: API::V1::Entities::OTPSecret)
    end

    desc 'Enable 2FA.'
    params { use :enable }
    put :enable do
      enabling = Services::OTP::Enable.new(current_user, params[:code])
      enabling.call

      if enabling.error == Services::OTP::Enable::ERROR_INVALID_CODE
        fail API::V1::Errors::ValidationError, { otp: ['is invalid'] }
      elsif enabling.error == Services::OTP::Enable::ERROR_ALREADY_ENABLED
        fail API::V1::Errors::OTP::AlreadyEnabledError
      end

      enabling.backup_codes
    end

    desc 'Disable 2FA.'
    params { use :disable }
    put :disable do
      disabling = Services::OTP::Disable.new(current_user, params[:password])
      disabling.call

      if disabling.error == Services::OTP::Disable::ERROR_PASSWORD_INVALID
        fail API::V1::Errors::ValidationError, { password: ['is invalid'] }
      elsif disabling.error == Services::OTP::Disable::ERROR_OTP_NOT_ENABLED
        fail API::V1::Errors::OTP::NotEnabledError
      end
    end

    desc 'Re-create backup codes for 2FA.'
    params { use :backup_codes }
    put :backup_codes do
      regenerating = Services::OTP::RegenerateBackupCodes.new(current_user, params[:password])
      regenerating.call
      if regenerating.error == Services::OTP::RegenerateBackupCodes::ERROR_PASSWORD_INVALID
        fail API::V1::Errors::ValidationError.new({ password: ['is invalid'] })
      elsif regenerating.error ==  Services::OTP::RegenerateBackupCodes::ERROR_OTP_REQUIRED
        fail API::V1::Errors::OTP::NotEnabledError
      end

      regenerating.codes
    end
  end
end
