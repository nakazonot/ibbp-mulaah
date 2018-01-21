class API::V1::Calculations < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Calculations

  resource :calculations do
    resource :estimates do
      desc 'Calculate estimated price of tokens.'
      params { use :estimates_currencies }
      get :currencies do
        fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)

        calculations = Services::Calculations::CoinsToPrice.new(current_user, params[:coin_amount]).call
        APIEstimatedPricesFormatter.new(calculations).view_data
      end

      desc 'Calculate estimated number of tokens.'
      params { use :estimates_tokens }
      get :tokens do
        fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)

        calculations = Services::Calculations::PriceToCoins.new(current_user, params[:coin_price]).call
        APIEstimatedTokensFormatter.new(calculations).view_data
      end
    end

    resource :prices do
      desc 'Calculates the cost when buying tokens.'
      params { use :estimates_currencies }
      get do
        fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)

        result = Services::Calculations::CoinsToPrice.new(current_user, params[:coin_amount], true).call

        CoinPriceFormatter.new(result, true).view_data
      end

      desc 'Calculates the cost when buying tokens for the whole deposit.'
      get :all_deposits do
        fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)

        result = Services::Calculations::CoinsForAllDeposits.new(current_user).call

        CoinPriceForAllBalancesFormatter.new(result, true).view_data
      end
    end
  end
end
