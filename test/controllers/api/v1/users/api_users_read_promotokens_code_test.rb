require 'test_helper'

class APIUsersReadPromotokensCodeTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/promotokens/code' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/promotokens/code'

      assert_equal 401, response_status
      assert_equal API::V1::Errors::Types::USER_UNAUTHENTICATED_ERROR, response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'when promotoken code not exist' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      create(:payment_balance_btc, user: user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/promotokens/code'

      assert_equal 200, response_status
      assert_nil response_json
    end

    test 'when promotoken code exist' do
      user       = create(:user)
      token      = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      promotoken = create(:promocode, is_promo_token: true)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/promotokens/code'

      assert_equal 200, response_status
      assert_equal response_json, present(promotoken, API::V1::Entities::Promotoken)
    end
  end
end
