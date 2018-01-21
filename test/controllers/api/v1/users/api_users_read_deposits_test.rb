require 'test_helper'

class APIUsersReadDepositsTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/deposits' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/deposits'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'deposits empty' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/deposits'

      assert_equal 200, response_status
      assert_empty response_json
    end

    test 'deposit exist for single currency' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_eth, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/deposits'

      assert_equal 200, response_status
      assert_equal 200.0, response_json['ETH']
    end

    test 'deposit exist for multiple currency' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/deposits'

      assert_equal 200, response_status
      assert_equal 200.0, response_json['ETH']
      assert_equal 20.0, response_json['BTC']
      assert_equal 1000.0, response_json['USD']
    end
  end
end
