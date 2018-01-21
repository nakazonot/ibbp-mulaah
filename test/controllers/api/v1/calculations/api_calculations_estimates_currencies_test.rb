require 'test_helper'

class APICalculationsEstimatesCurrenciesTest < ActiveSupport::TestCase
  describe 'GET /api/calculations/estimates/currencies' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/calculations/estimates/currencies', {
        coin_amount: 10
      }

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.',response_json['error']['details']
    end

    test 'unauthorized fail token' do
      API::V1::Defaults.expects(:log_error)

      header('Authorization', 'Bearer api_token')
      get '/api/calculations/estimates/currencies', {
        coin_amount: 10
      }

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.',response_json['error']['details']
    end

    test 'invalid coin_amount value' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/currencies', {
        coin_amount: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'],response_json['error']['details']['coin_amount']
    end

    test 'correct params, coin_amount positive' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/currencies', {
        coin_amount: 10
      }

      expected_body_btc = {
        'coin_price'        => 0.1,
        'coin_amount'       => 10,
        'coin_amount_bonus' => 1,
        'coin_amount_total' => 11,
        'bonus_percent'     => 10
      }

      assert_equal 200, response_status
      assert_equal expected_body_btc, response_json['currencies']['BTC']
    end

    test 'correct params, coin_amount zero' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/currencies', {
        coin_amount: 0
      }

      expected_body_btc = {
        'coin_price'        => 0,
        'coin_amount'       => 0,
        'coin_amount_bonus' => 0,
        'coin_amount_total' => 0,
        'bonus_percent'     => 10
      }

      assert_equal 200, response_status
      assert_equal expected_body_btc, response_json['currencies']['BTC']
    end

    test 'correct params, coin_amount negative' do
      API::V1::Defaults.expects(:log_error)

      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/currencies', {
        coin_amount: -5
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['must be greater than 0'], response_json['error']['details']['coin_amount']
    end
  end
end