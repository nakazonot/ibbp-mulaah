require 'test_helper'

class APIUsersSignUpTest < ActiveSupport::TestCase
  describe 'POST /api/users/registrations' do
    test 'correct params without name, without confirmation' do
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('1')

      user_attributes = {
        email: 'test@mail.ru',
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
        confirmation_uri_base: 'http://test.ru'
      }

      post '/api/users/registrations', user_attributes

      assert_includes response_header['Authorization'], 'Bearer'
      assert_equal 201, response_status
      assert_equal user_attributes[:email], User.find(response_json['id']).email
    end

    test 'correct params without name, with confirmation enabled' do
      user_attributes = {
        email:                 'test@mail.ru',
        password:              'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
        confirmation_uri_base: 'http://test.ru',
        referral_uri_base: '    http://test.ru'
      }

      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
      User.any_instance.expects(:send_confirmation_notification_from_api)

      post '/api/users/registrations', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 201, response_status
      assert_equal user_attributes[:email], User.find(response_json['id']).email
    end

    test 'correct params, with confirmation enabled (by KYC)' do
      user_attributes = {
        email: 'test@mail.ru',
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
        confirmation_uri_base: 'http://test.ru',
        referral_uri_base: 'http://test.ru'
      }

      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('1')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
      User.any_instance.expects(:send_confirmation_notification_from_api)

      post '/api/users/registrations', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 201, response_status
      assert_equal user_attributes[:email], User.find(response_json['id']).email
    end

    test 'correct params with name' do
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('1')

      user_attributes = {
        email: 'test@mail.ru',
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
        name: 'Vasya'
      }

      post '/api/users/registrations', user_attributes

      assert_includes response_header['Authorization'], 'Bearer'
      assert_equal 201, response_status
      assert_equal user_attributes[:name], User.find(response_json['id']).name
    end

    test 'correct params, but email already exist' do
      API::V1::Defaults.expects(:log_error)

      user            = create(:user)
      user_attributes = {
        email: user.email,
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
      }

      post '/api/users/registrations', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['has already been taken'], response_json['error']['details']['email']
    end

    test 'correct params with referral_code' do
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('1')

      referral        = create(:user)
      user_attributes = {
        email: 'test@mail.ru',
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true,
        referral_code: referral.referral_uuid
      }

      post '/api/users/registrations', user_attributes

      assert_includes response_header['Authorization'], 'Bearer'
      assert_equal 201, response_status
      assert_equal referral.id, User.find(response_json['id']).referral_id
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/registrations'

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is missing'], response_json['error']['details']['email']
    end

    test 'invalid email' do
      API::V1::Defaults.expects(:log_error)

      user_attributes = {
        email: 'test',
        password: 'password0A',
        password_confirmation: 'password0A',
        registration_agreement: true
      }

      post '/api/users/registrations', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['email']
    end

    test 'incorrect password (too simple)' do
      API::V1::Defaults.expects(:log_error)

      user_attributes = {
        email: 'test@mail.ru',
        password: '123456',
        password_confirmation: '123456',
        registration_agreement: true
      }

      post '/api/users/registrations', user_attributes

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is too short (minimum is 8 characters)', 'must include at least one lowercase letter, one uppercase letter, and one digit'],
                   response_json['error']['details']['password']
    end
  end
end
