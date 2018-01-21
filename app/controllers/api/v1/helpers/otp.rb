module API::V1::Helpers::OTP
  extend Grape::API::Helpers

  params :disable do
    requires :password,               type: String,   desc: 'Password'
  end

  params :enable do
    requires :code,                   type: String,   desc: 'Code from 2FA app or backup-code'
  end

  params :backup_codes do
    requires :password,               type: String,   desc: 'Password'
  end
end
