require 'test_helper'

class APICalculationsEstimatesTokensTest < ActiveSupport::TestCase
  describe 'GET /api/calculations/estimates/tokens' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/calculations/estimates/tokens', {
        coin_price: 10
      }

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'invalid amount - string' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/tokens', {
        coin_price: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['coin_price']
    end

    test 'correct params, positive amount' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/tokens', {
        coin_price: 10
      }

      expected_body_btc = {
        'coin_price'        => 10,
        'coin_amount'       => 1000,
        'coin_amount_bonus' => 100,
        'coin_amount_total' => 1100,
        'bonus_percent'     => 10
      }

      assert_equal 200, response_status
      assert_equal expected_body_btc, response_json['currencies']['BTC']
    end

    test 'correct params, zero amount' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/tokens', {
        coin_price: 0
      }

      expected_body_btc = {
        'coin_price'        => 0.0,
        'coin_amount'       => 0.0,
        'coin_amount_bonus' => 0.0,
        'coin_amount_total' => 0.0,
        'bonus_percent'     => 10
      }

      assert_equal 200, response_status
      assert_equal expected_body_btc, response_json['currencies']['BTC']
    end

    test 'correct params, negative amount' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/calculations/estimates/tokens', {
        coin_price: -5
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['must be greater than 0'], response_json['error']['details']['coin_price']
    end
  end
end