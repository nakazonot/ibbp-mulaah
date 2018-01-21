require 'test_helper'

class APIUsersPasswordEditTest < ActiveSupport::TestCase
  describe 'PUT /api/users/passwords' do
    test 'correct params' do
      user                 = create(:user)
      reset_password_token = user.set_reset_password_token!

      put '/api/users/passwords', {
        reset_password_token: reset_password_token,
        password: 'password0B',
        password_confirmation: 'password0B'
      }

      assert_nil response_header['Authorization']
      assert_equal 200, response_status
      assert_equal user, User.find(response_json['id'])
      assert_not_nil response_json['id']
      assert_not_nil user.reload.confirmed_at
    end

    test 'password not match' do
      API::V1::Defaults.expects(:log_error)

      user                 = create(:user)
      reset_password_token = user.set_reset_password_token!

      put '/api/users/passwords', {
        reset_password_token: reset_password_token,
        password: '123456781aA',
        password_confirmation: '123456781aB'
      }

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['doesn\'t match Password'], response_json['error']['details']['password_confirmation']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'invalid password length' do
      API::V1::Defaults.expects(:log_error)

      user                 = create(:user)
      reset_password_token = user.set_reset_password_token!

      put '/api/users/passwords', {
        reset_password_token: reset_password_token,
        password: '1a!A56',
        password_confirmation: '1a!A56'
      }

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is too short (minimum is 8 characters)'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'invalid password format' do
      API::V1::Defaults.expects(:log_error)

      user                 = create(:user)
      reset_password_token = user.set_reset_password_token!

      put '/api/users/passwords', {
        reset_password_token: reset_password_token,
        password: '12345678',
        password_confirmation: '12345678'
      }

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['must include at least one lowercase letter, one uppercase letter, and one digit'], response_json['error']['details']['password']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'invalid token' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/passwords', {
        reset_password_token: SecureRandom.hex(8),
        password: SecureRandom.hex(8),
        password_confirmation: SecureRandom.hex(8)
      }

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['reset_password_token']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/passwords'

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['reset_password_token']
      assert_equal ['is missing'], response_json['error']['details']['password']
      assert_equal ['is missing'], response_json['error']['details']['password_confirmation']
      assert_equal 'validation_error', response_json['error']['type']
    end
  end
end
