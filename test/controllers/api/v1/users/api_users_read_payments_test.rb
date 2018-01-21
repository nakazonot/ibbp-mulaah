require 'test_helper'

class APIUsersReadPaymentsTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/payments' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/payments'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'payments empty' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments'

      assert_equal 200, response_status
      assert_empty response_json['data']
      assert_empty response_json['meta']['types']
    end

    test 'exist payment' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments'

      assert_equal 200, response_status
      assert_equal 'BTC', response_json['data'].first['currency']
      assert_equal '20', response_json['data'].first['amount']
      assert_equal 'balance', response_json['data'].first['type']
      assert_not_empty response_json['meta']['types']
      assert_nil response_json['data'].first['ico_currency_amount']
    end

    test 'pagination info in headers' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments'

      assert_equal 200, response_status
      assert_equal '3', response_header['X-Total']
      assert_equal '1', response_header['X-Page']
      assert_equal '10', response_header['X-Per-Page']
      assert_not_empty response_json['meta']['types']
      assert_equal 3, response_json['data'].count
    end

    test 'invalid order_column and order_direction' do
      API::V1::Defaults.expects(:log_error)

      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      # create(:payment_balance_btc, user: user)
      # create(:payment_balance_eth, user: user)
      # create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments', {
        order_column: SecureRandom.hex,
        order_direction: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['order_column']
      assert_equal ['is invalid'], response_json['error']['details']['order_direction']
    end

    test 'valid order_column and order_direction' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments', {
        order_column: 'created_at',
        order_direction: 'desc'
      }

      assert_equal 200, response_status
      assert_not_empty response_json['meta']['types']

      assert response_json['data'].first['created_at'] > response_json['data'].last['created_at']
    end

    test 'set only order_direction' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_usd, user: user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments', {
        order_direction: 'desc'
      }

      assert_equal 200, response_status
      assert_not_empty response_json['meta']['types']
      assert response_json['data'].first['id'] > response_json['data'].last['id']
    end

    test 'set only order_column' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_usd, user: user, amount_buyer: 1000)
      create(:payment_balance_btc, user: user, amount_buyer: 10)
      create(:payment_balance_eth, user: user, amount_buyer: 100)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/payments', {
        order_column: 'currency'
      }

      assert_equal 200, response_status
      assert_not_empty response_json['meta']['types']
      assert_equal 'BTC', response_json['data'].first['currency']
      assert_equal 'USD', response_json['data'].last['currency']
    end
  end
end
