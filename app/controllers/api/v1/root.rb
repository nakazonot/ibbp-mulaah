require 'grape-swagger'

module API
  module V1
    class Root < Grape::API
      mount API::V1::Users
      mount API::V1::Calculations
      mount API::V1::OTP
      mount API::V1::Invoices
      mount API::V1::Deposits
      mount API::V1::Contracts
      mount API::V1::Parameters
      mount API::V1::Infos
      mount API::V1::Translations

      add_swagger_documentation(
        api_version: 'v1',
        version: 'v1',
        hide_documentation_path: true,
        hide_format: true,
        format: :json,
        info: {
          title: 'IBBP',
          description: 'Documentation for IBBP API.'
        }
      )
    end
  end
end
