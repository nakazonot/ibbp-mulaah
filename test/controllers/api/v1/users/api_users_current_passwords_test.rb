require 'test_helper'

class APIUsersCurrentPasswordsTest < ActiveSupport::TestCase
  describe 'PUT /api/users/current/passwords' do
    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/current/passwords'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'without params' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current/passwords'

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['is missing'], response_json['error']['details']['current_password']
      assert_equal ['is missing'], response_json['error']['details']['password']
      assert_equal ['is missing'], response_json['error']['details']['password_confirmation']
    end

    test 'with uses_default_password' do
      API::V1::Defaults.expects(:log_error)

      current_password = User.generate_random_password
      password         = User.generate_random_password
      user             = create(:user, password: current_password, uses_default_password: true)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current/passwords', {
        current_password:      current_password,
        password:              password,
        password_confirmation: password
      }

      assert_equal 403, response_status
      assert_equal API::V1::Errors::Types::USER_NEED_SET_PASSWORD_ERROR, response_json['error']['type']
      assert_equal 'You must set a password before this action.', response_json['error']['details']
    end

    test 'incorrect current_password' do
      API::V1::Defaults.expects(:log_error)

      current_password = User.generate_random_password
      password         = User.generate_random_password
      user             = create(:user, password: current_password)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current/passwords', {
        current_password:      SecureRandom.hex,
        password:              password,
        password_confirmation: password
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['current_password']
    end

    test 'invalid password confirmation' do
      API::V1::Defaults.expects(:log_error)

      current_password = User.generate_random_password
      password         = User.generate_random_password
      user             = create(:user, password: current_password)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current/passwords', {
        current_password:      current_password,
        password:              password,
        password_confirmation: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['doesn\'t match Password'], response_json['error']['details']['password_confirmation']
    end

    test 'valid all params' do
      current_password = User.generate_random_password
      password         = User.generate_random_password
      user             = create(:user, password: current_password)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current/passwords', {
        current_password:      current_password,
        password:              password,
        password_confirmation: password
      }

      assert_equal 200, response_status
      assert_equal present(user, API::V1::Entities::User), response_json
    end
  end
end
