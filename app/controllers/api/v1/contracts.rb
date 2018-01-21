class API::V1::Contracts < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Contracts

  resource :contracts do
    before do
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:buy_tokens, :user_kyc)
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:buy_tokens, :stage)
    end

    desc 'Generate contract for buying tokens.'
    params { use :generate_contract }
    post do
      contract = Services::Coin::ContractCreator.new(params, current_user).call
      fail API::V1::Errors::Contracts::CreateError, contract[:error] if contract[:error].present?

      present(contract, with: API::V1::Entities::Contract)
    end

    desc 'Buy tokens with a contract.'
    params { use :accept_contract }
    post ':id/buy_tokens' do
      contract = BuyTokensContract.find_by!(id: params[:id])
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:sign_contract, contract)

      coin_creator  = Services::Coin::CoinCreator.new(contract, request: request).call
      fail API::V1::Errors::Contracts::AcceptError, coin_creator[:msg] if coin_creator[:error].present?

      nil
    end
  end
end
