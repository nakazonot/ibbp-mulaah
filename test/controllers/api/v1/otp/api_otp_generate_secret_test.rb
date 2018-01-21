require 'test_helper'

class APIOTPGenerateSecretTest < ActiveSupport::TestCase
  describe 'POST /api/otp/secrets' do
    test 'user without enabled 2FA' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      post '/api/otp/secrets'

      assert_equal 201, response_status
      assert_not_nil response_json['secret']
      assert_not_nil response_json['label']
      assert_not_nil response_json['uri']
    end

    test 'user with enabled 2FA' do
      user  = create(:user, otp_required_for_login: true)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      post '/api/otp/secrets'

      assert_equal 201, response_status
      assert_not_nil(response_json['secret'])
      assert_not_nil(response_json['label'])
      assert_not_nil(response_json['uri'])
    end

    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      post '/api/otp/secrets'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end
  end
end
