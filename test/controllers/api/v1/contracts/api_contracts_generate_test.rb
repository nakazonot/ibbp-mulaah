require 'test_helper'

class APIContractsGenerateTest < ActiveSupport::TestCase
  describe 'POST /api/contracts/:currency' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      post '/api/contracts'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.',response_json['error']['details']
    end

    test 'authorized with balance' do
      user            = create(:user)
      token           = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)
      contract_params = { currency: 'BTC', coin_amount: 4, coin_price: 0.04, buy_from_all_balance: false }
      calculations    = Services::Calculations::CoinsToPrice.new(user, contract_params[:coin_amount], true).call

      header('Authorization', "Bearer #{token}")
      post '/api/contracts', contract_params

      assert_equal 201, response_status
      assert_equal coins_number_format(calculations[:coin_amount]).to_f, response_json['coin_amount']
      assert_equal coins_number_format(calculations[:coin_amount_bonus]).to_f, response_json['coin_amount_bonus']
      assert_equal contract_params[:currency], response_json['currency']
      assert_not_nil response_json['uuid']
      assert_not_nil response_json['purchase_agreement_uri']
    end

    test 'authorized with balance all_deposit' do
      user            = create(:user)
      token           = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_usd, user: user)
      contract_params = { currency: 'BTC', coin_amount: 3220.8, coin_price: 32.208, buy_from_all_balance: true }
      calculations = Services::Calculations::CoinsForAllDeposits.new(user).call

      header('Authorization', "Bearer #{token}")
      post '/api/contracts', contract_params

      assert_equal 201, response_status
      assert_equal coins_number_format(calculations[:coin_amount]).to_f, response_json['coin_amount']
      assert_equal coins_number_format(calculations[:coin_amount_bonus]).to_f, response_json['coin_amount_bonus']
      assert_equal contract_params[:currency], response_json['currency']
      assert_not_nil response_json['uuid']
      assert_not_nil response_json['purchase_agreement_uri']
    end

    test 'authorized without balance' do
      API::V1::Defaults.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/contracts', {
        currency:   'BTC',
        coin_amount: 16,
        coin_price: 0.16,
        buy_from_all_balance: false
      }

      assert_equal 409, response_status
      assert_equal 'contract_create_error', response_json['error']['type']
      assert_equal 'You do not have enough funds on your BTC balance', response_json['error']['details']
    end

    test 'no access to buy tokens' do
      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:buy_token_enabled).returns(false)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/contracts', {
        currency:   'BTC',
        coin_amount: 16,
        coin_price: 0.16,
        buy_from_all_balance: false
      }

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'no access to show ICO info' do
      API::V1::Defaults.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      Ability.any_instance.stubs(:can?).with(:make_deposits, :user_kyc).returns(true)
      Ability.any_instance.stubs(:can?).with(:show_ico_info, :user).returns(false)

      header('Authorization', "Bearer #{token}")
      post '/api/contracts', {
        currency:   'BTC',
        coin_amount: 16,
        coin_price:  0.16,
        buy_from_all_balance: false
      }

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end
  end
end
