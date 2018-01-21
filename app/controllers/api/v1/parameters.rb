class API::V1::Parameters < Grape::API
  include API::V1::Defaults

  resource :parameters do
    desc 'Get all parameters.'
    get do
      parameters = Parameter.get_all.clone
      parameters['available_currencies']           = Parameter.available_currencies
      parameters['min_payment_amount_by_currency'] = Parameter.min_payment_amount_by_currency
      parameters['ico_enabled']                    = Parameter.ico_enabled
      parameters['purchase_agreements']            = Parameter.get_purchase_agreements

      parameters
    end
  end
end
