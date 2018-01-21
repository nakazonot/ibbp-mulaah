require 'test_helper'

class APIOTPBackupCodesTest < ActiveSupport::TestCase
  describe 'PUT /api/otp/backup_codes' do
    test 'correct password' do
      password      = 'password0A'
      user          = create(:user, password: password)
      user.create_otp_secret!
      user.enable_two_factor!
      token         = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      backup_codes  = user.otp_backup_codes

      header('Authorization', "Bearer #{token}")

      put '/api/otp/backup_codes', {
        password: password
      }

      assert_equal 200, response_status
      assert_not_nil response_json
      assert_not_equal user.reload.otp_backup_codes, backup_codes
    end

    test 'incorrect password' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::RegenerateBackupCodes.any_instance.expects(:log_error)

      user          = create(:user)
      user.create_otp_secret!
      user.enable_two_factor!
      token         = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      backup_codes  = user.otp_backup_codes

      header('Authorization', "Bearer #{token}")

      put '/api/otp/backup_codes', {
        password: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal backup_codes, user.reload.otp_backup_codes
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      user = create(:user)
      user.create_otp_secret!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/backup_codes'

      assert_nil user.reload.otp_required_for_login
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      put '/api/otp/backup_codes'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test '2FA not enabled' do
      API::V1::Defaults.expects(:log_error)
      Services::OTP::RegenerateBackupCodes.any_instance.expects(:log_error)

      user = create(:user, password: 'password0A')
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      put '/api/otp/backup_codes', {
        password: user.password
      }

      assert_equal 403, response_status
      assert_equal 'Two-factor authentication not enabled.', response_json['error']['details']
      assert_equal 'otp_not_enabled_error', response_json['error']['type']
    end
  end
end
