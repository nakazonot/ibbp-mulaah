require 'test_helper'

class APICalculationsPricesTest < ActiveSupport::TestCase
  describe 'GET /api/calculations/prices' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/calculations/prices', {
        coin_amount: 10
      }

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'invalid coin_amount - string' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices', {
        coin_amount: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['coin_amount']
    end

    test 'positive coin_amount' do
      user   = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices', {
        coin_amount: 10
      }

      expected_body = {
        'coin_amount'       => 10,
        'coin_amount_bonus' => 1,
        'coin_amount_total' => 11,
        'bonus_percent'     => 10,
        'currencies'        => {
          'BTC'  => 0.1,
          'LTC'  => 9.6154,
          'XRP'  => 1960.7844,
          'DASH' => 1.7398,
          'ETC'  => 44.1697,
          'ETH'  => 1.6642,
          'USD'  => 526.32
        }
      }

      assert_equal 200, response_status
      assert_equal expected_body, response_json
    end

    test 'zero coin_amount' do
      user   = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices', {
        coin_amount: 0
      }

      expected_body = {
        'coin_amount'       => 0,
        'coin_amount_bonus' => 0,
        'coin_amount_total' => 0,
        'bonus_percent'     => 10,
        'currencies'        => {
          'BTC'  => 0,
          'LTC'  => 0,
          'XRP'  => 0,
          'DASH' => 0,
          'ETC'  => 0,
          'ETH'  => 0,
          'USD'  => 0.00
        }
      }

      assert_equal 200, response_status
      assert_equal expected_body, response_json
    end

    test 'negative coin_amount' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/prices', {
        coin_amount: -5
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['must be greater than 0'],response_json['error']['details']['coin_amount']
    end
  end
end