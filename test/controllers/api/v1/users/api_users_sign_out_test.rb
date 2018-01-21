require 'test_helper'

class APIUsersSignOutTest < ActiveSupport::TestCase
  describe 'DELETE /api/users/sessions' do
    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      delete '/api/users/sessions'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'incorrect auth-token' do
      API::V1::Defaults.expects(:log_error)

      header('Authorization', 'Bearer incorrect-auth-token')

      delete '/api/users/sessions'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'correct auth-token' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      delete '/api/users/sessions'

      assert_equal 204, response_status
      assert_raise Warden::JWTAuth::Errors::RevokedToken do
        Warden::JWTAuth::UserDecoder.new.call(token, :user)
      end
    end
  end
end
