require 'test_helper'

class APIUsersTokensTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/tokens' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/tokens'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'user with zero balances' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/tokens'

      assert_equal 200, response_status
      assert_equal 0.0, response_json['coin_count']
      assert_equal 0.0, response_json['referral_coin_count']
    end

    test 'user with purchase' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      create(:payment_purchase_tokens, user: user)
      create(:payment_referral_bounty, user: user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/tokens'

      assert_equal 200, response_status
      assert_equal 1.0, response_json['coin_count']
      assert_equal 2.0, response_json['referral_coin_count']
    end
  end
end
