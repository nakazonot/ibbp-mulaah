require 'test_helper'

class APIOTPEnableTest < ActiveSupport::TestCase
  describe 'PUT /api/otp/secrets' do
    test 'correct code' do
      user = create(:user)
      user.create_otp_secret!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/enable', {
        code: user.current_otp
      }

      assert_equal 200, response_status
      assert_equal true, user.reload.otp_required_for_login
      assert_not_nil response_json
    end

    test 'incorrect code' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::Enable.any_instance.expects(:log_error)

      user = create(:user)
      user.create_otp_secret!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/enable', {
        code: (user.current_otp.to_i + 1)
      }

      assert_nil user.reload.otp_required_for_login
      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['otp']
      assert_equal 'validation_error', response_json['error']['type']
      assert_not_includes response_json, 'backup_codes'
    end

    test 'already enabled' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::Enable.any_instance.expects(:log_error)

      user = create(:user, otp_required_for_login: true)
      user.create_otp_secret!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/otp/enable', {
        code: (user.current_otp.to_i)
      }

      assert_equal 403, response_status
      assert_equal 'Two-factor authentication already enabled.', response_json['error']['details']
      assert_equal API::V1::Errors::Types::OTP_ALREADY_ENABLED_ERROR, response_json['error']['type']
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      user = create(:user)
      user.create_otp_secret!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/enable'

      assert_nil user.reload.otp_required_for_login
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['code']
      assert_equal 'validation_error', response_json['error']['type']
      assert_not_includes response_json, 'backup_codes'
    end

    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      put '/api/otp/enable'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end
  end
end
