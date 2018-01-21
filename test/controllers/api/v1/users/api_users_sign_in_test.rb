require 'test_helper'

class APIUsersSignInTest < ActiveSupport::TestCase
  describe 'POST /api/users/sessions' do
    test 'correct params' do
      user_attributes   = { email: 'test@mail.ru', password: 'password0A' }
      user              = create(:user, user_attributes)

      post '/api/users/sessions', user_attributes

      assert_includes response_header['Authorization'], 'Bearer'
      assert_equal 201, response_status
      assert_equal user, User.find(response_json['id'])
    end

    test 'non-existent email' do
      API::V1::Defaults.expects(:log_error)

      user_attributes  = { email: 'test@mail.ru', password: 'password0A' }

      post '/api/users/sessions', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 401, response_status
      assert_equal 'Invalid email or password.', response_json['error']['details']
      assert_equal 'user_login_error', response_json['error']['type']
    end

    test 'incorrect password' do
      API::V1::Defaults.expects(:log_error)

      user_attributes  = { email: 'test@mail.ru', password: 'password0A' }

      create(:user, user_attributes)

      post '/api/users/sessions', {
        email: user_attributes[:email],
        password: 'password0B'
      }

      assert_nil response_header['Authorization']
      assert_equal 401, response_status
      assert_equal 'Invalid email or password.', response_json['error']['details']
      assert_equal 'user_login_error', response_json['error']['type']
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/sessions'

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['email']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test '2fa enabled, otp not set in params' do
      API::V1::Defaults.expects(:log_error)

      user_attributes  = { email: 'test@mail.ru', password: 'password0A' }
      user             = create(:user, user_attributes)

      user.create_otp_secret!
      user.enable_two_factor!

      post '/api/users/sessions', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 401, response_status
      assert_equal 'Two-Factor Authorization enabled in account, need code.', response_json['error']['details']
      assert_equal 'otp_required_error', response_json['error']['type']
    end

    test '2fa enabled, otp incorrect' do
      API::V1::Defaults.expects(:log_error)

      user_attributes  = { email: 'test@mail.ru', password: 'password0A' }
      user             = create(:user, user_attributes)

      user.create_otp_secret!
      user.enable_two_factor!

      post '/api/users/sessions', {
        email: user_attributes[:email],
        password: user_attributes[:password],
        otp: 0
      }

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['otp']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test '2fa enabled, otp correct' do
      user_attributes  = { email: 'test@mail.ru', password: 'password0A' }
      user             = create(:user, user_attributes)

      user.create_otp_secret!
      user.enable_two_factor!

      post '/api/users/sessions', {
        email: user_attributes[:email],
        password: user_attributes[:password],
        otp: user.current_otp
      }

      assert_equal 201, response_status
      assert_includes response_header['Authorization'], 'Bearer'
      assert_not_nil response_json['id']
      assert_equal user, User.find(response_json['id'])
    end

    test 'incorrect password, max attempts was exhausted' do
      max_devise_attempts = ENV.fetch('DEVISE_MAXIMUM_ATTEMPTS', 10).to_i
      API::V1::Defaults.expects(:log_error).times(max_devise_attempts + 1)

      user_attributes   = { email: 'test@mail.ru', password: 'password0A' }
      user              = create(:user, user_attributes)
      unlock_uri        = 'http://test.ru'

      User.any_instance.expects(:send_unlock_instructions_from_api).with(unlock_uri).once

      (0...max_devise_attempts).each do
        post '/api/users/sessions', {
          email: user_attributes[:email],
          password: 'password0B',
          unlock_uri: 'http://test.ru'
        }
      end

      post '/api/users/sessions', {
        email: user_attributes[:email],
        password: user_attributes[:password],
        unlock_uri: unlock_uri
      }

      assert_nil response_header['Authorization']
      assert_equal 403, response_status
      assert_equal 'Your account is locked.', response_json['error']['details']
      assert_equal 'user_locked_error', response_json['error']['type']
    end

    test 'incorrect OTP, max attempts was exhausted' do
      max_devise_attempts = ENV.fetch('DEVISE_MAXIMUM_ATTEMPTS', 10).to_i

      API::V1::Defaults.expects(:log_error).times(max_devise_attempts + 1)

      user_attributes   = { email: 'test@mail.ru', password: 'password0A' }
      user              = create(:user, user_attributes)
      unlock_uri        = 'http://test.ru'

      user.create_otp_secret!
      user.enable_two_factor!

      User.any_instance.expects(:send_unlock_instructions_from_api).with('http://test.ru').once

      (0...max_devise_attempts).each do
        post '/api/users/sessions', {
          email: user_attributes[:email],
          password: 'password0B',
          otp: 0,
          unlock_uri: 'http://test.ru'
        }
      end

      post '/api/users/sessions', {
        email: user_attributes[:email],
        password: user_attributes[:password],
        otp: user.current_otp,
        unlock_uri: unlock_uri
      }

      assert_nil response_header['Authorization']
      assert_equal 403, response_status
      assert_equal 'Your account is locked.', response_json['error']['details']
      assert_equal 'user_locked_error', response_json['error']['type']
    end
  end
end
