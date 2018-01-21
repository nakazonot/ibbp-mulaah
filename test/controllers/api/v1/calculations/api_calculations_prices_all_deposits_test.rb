require 'test_helper'

class APICalculationsPricesAllDepositsTest < ActiveSupport::TestCase
  describe 'GET /api/calculations/prices/all_deposits' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/calculations/prices/all_deposits'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'empty balance' do
      user   = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices/all_deposits'

      expected_body = {
        'one_currency'      => true,
        'coin_amount'       => 0,
        'coin_price'        => 0,
        'coin_amount_bonus' => 0,
        'bonus_percent'     => 10,
        'currency'          => 'BTC'
      }

      assert_equal 200, response_status
      assert_equal expected_body, response_json
    end

    test 'single deposit' do
      user   = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_eth, user: user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices/all_deposits'

      assert_equal 200, last_response.status

      expected_body = {
        'one_currency'      => true,
        'coin_amount'       => 1201.8,
        'coin_price'        => 200,
        'coin_amount_bonus' => 120.18,
        'bonus_percent'     => 10,
        'currency'          => 'ETH'
      }

      assert_equal 200, response_status
      assert_equal expected_body, response_json
    end

    test 'multiple deposit' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices/all_deposits'

      expected_body = {
        'one_currency'      => false,
        'coin_amount'       => 3220.8,
        'coin_price'        => 32.208,
        'coin_amount_bonus' => 322.08,
        'bonus_percent'     => 10,
        'currency'          => 'BTC',
        'balances'          => {
          'BTC' => 20,
          'ETH' => 200,
          'USD' => 1000.00
        }
      }

      assert_equal 200, response_status
      assert_equal expected_body, response_json
    end
  end
end