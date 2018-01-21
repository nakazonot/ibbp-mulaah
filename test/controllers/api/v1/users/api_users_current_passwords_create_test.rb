require 'test_helper'

class APIUsersCurrentPasswordsCreateTest < ActiveSupport::TestCase
  describe 'POST /api/users/current/passwords' do
    test 'without auth-token' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/current/passwords'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'without params' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/passwords'

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['is missing'], response_json['error']['details']['password']
      assert_equal ['is missing'], response_json['error']['details']['password_confirmation']
    end

    test 'where uses_default_password is false' do
      API::V1::Defaults.expects(:log_error)

      password         = User.generate_random_password
      user             = create(:user, uses_default_password: false)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/passwords', {
        password:              password,
        password_confirmation: password
      }

      assert_equal 403, response_status
      assert_equal API::V1::Errors::Types::NOT_AUTHORIZED_ERROR, response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'invalid password confirmation' do
      API::V1::Defaults.expects(:log_error)

      password         = User.generate_random_password
      user             = create(:user, uses_default_password: true)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/passwords', {
        password:              password,
        password_confirmation: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['doesn\'t match Password'], response_json['error']['details']['password_confirmation']
    end

    test 'too simple password' do
      API::V1::Defaults.expects(:log_error)

      password         = '0000'
      user             = create(:user, uses_default_password: true)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/passwords', {
        password:              password,
        password_confirmation: password
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal [
                     'is too short (minimum is 8 characters)',
                     'must include at least one lowercase letter, one uppercase letter, and one digit'
                   ], response_json['error']['details']['password']
    end

    test 'valid all params' do
      password         = User.generate_random_password
      user             = create(:user, uses_default_password: true)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/passwords', {
        password:              password,
        password_confirmation: password
      }

      assert_equal 201, response_status
      assert_equal present(user.reload, API::V1::Entities::User), response_json
    end
  end
end
