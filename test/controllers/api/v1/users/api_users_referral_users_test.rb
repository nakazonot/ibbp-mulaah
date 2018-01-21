require 'test_helper'

class APIUsersReferralUsersTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/referral_users' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/referral_users'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'without referrals' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/referral_users'

      assert_equal 200, response_status
      assert_empty response_json
    end

    test 'when not referrals enabled' do
      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:referral_system_enabled?).returns(false)

      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/referral_users'

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'when referral system "balance" and have referrals' do
      Parameter.stubs(:referral_system_enabled?).returns(true)
      Parameter.stubs(:referral_system_type?).with('tokens').returns(false)
      Parameter.stubs(:referral_system_type?).with('balance').returns(true)

      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      referral  = create(:user, referral_id: user.id)
      payment   = create(:payment_balance_btc, user: referral)
      create(:payment_referral_bounty_balance,
        user: user,
        parent_payment_id: payment.id,
        referral_user_id: referral.id
      )

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/referral_users'

      assert_equal 200, response_status
      assert_equal referral.email, response_json.first['email']
      assert_not_nil response_json.first['currencies']['BTC']
    end

    test 'when referral system "tokens" and have referrals' do
      Parameter.stubs(:referral_system_enabled?).returns(true)
      Parameter.stubs(:referral_system_type?).with('tokens').returns(true)
      Parameter.stubs(:referral_system_type?).with('balance').returns(false)

      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      referral  = create(:user, referral_id: user.id)
      payment   = create(:payment_purchase_tokens, user: referral)
      create(:payment_referral_bounty,
             user: user,
             parent_payment_id: payment.id,
             referral_user_id: referral.id
      )

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/referral_users'

      assert_equal 200, response_status
      assert_equal referral.email, response_json.first['email']
      assert_equal '2.0', response_json.first['bounty_amount']
    end
  end
end
