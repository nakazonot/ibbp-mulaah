class API::V1::Deposits < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Deposits

  before do
    fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)
    fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:make_deposits, :user_kyc)
    fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:make_deposits, :stage)
  end

  resource :deposits do
    resource :payment_addresses do
      desc 'Get all already generated payments.'
      get do
        PaymentAddress.deposit_addresses_by_user(current_user.id).each do |currency, address|
          present(currency.to_sym, address, with: API::V1::Entities::PaymentAddress)
        end
      end

      desc 'Get payment address for making deposit.'
      params { use :generate_address }
      post do
        address = Services::Coin::PaymentSystemAddressGetter.new(user: current_user, currency: params[:currency]).call
        fail API::V1::Errors::Deposits::AddressCreateError if address.nil?

        present(address.currency.to_sym, address, with: API::V1::Entities::PaymentAddress)
      end
    end
  end
end
