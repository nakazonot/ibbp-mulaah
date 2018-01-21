require 'test_helper'

class APIOTPDisableTest < ActiveSupport::TestCase
  describe 'PUT /api/otp/disable' do
    test 'correct password' do
      password  = 'password0A'
      user      = create(:user, password: password)
      user.create_otp_secret!
      user.enable_two_factor!
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/disable', {
        password: password
      }

      assert_equal 200, response_status
      assert_equal false, user.reload.otp_required_for_login
    end

    test 'otp not enabled' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::Disable.any_instance.expects(:log_error)

      password  = 'password0A'
      user      = create(:user, password: password)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/otp/disable', {
        password: password
      }

      assert_equal 403, response_status
      assert_equal 'Two-factor authentication not enabled.', response_json['error']['details']
      assert_equal API::V1::Errors::Types::OTP_NOT_ENABLED_ERROR, response_json['error']['type']
    end

    test 'incorrect password' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::Disable.any_instance.expects(:log_error)

      user      = create(:user)
      user.create_otp_secret!
      user.enable_two_factor!
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/otp/disable', {
        password: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal true, user.reload.otp_required_for_login
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      user = create(:user)
      user.create_otp_secret!
      user.enable_two_factor!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/disable'

      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal true, user.reload.otp_required_for_login
    end

    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      put '/api/otp/disable'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end
  end
end
