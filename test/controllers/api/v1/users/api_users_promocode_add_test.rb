require 'test_helper'

class APIUsersPromocodeAddTest < ActiveSupport::TestCase
  describe 'POST /api/users/current/promocodes' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/current/promocodes'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'without params' do
      API::V1::Defaults.expects(:log_error)

      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes'

      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['code']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'not exist' do
      API::V1::Defaults.expects(:log_error)

      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 404, response_status
      assert_equal 'The promo code does not exist', response_json['error']['details']
      assert_equal 'not_found_error', response_json['error']['type']
    end

    test 'not actual' do
      service   = mock()
      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      API::V1::Defaults.expects(:log_error)
      Services::Promocode::AddToUser.stubs(:new).returns(service)
      service.stubs(:call).returns(service)
      service.stubs(:error).returns(Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ACTUAL)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal ['not actual'], response_json['error']['details']['code']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'not valid' do
      service   = mock()
      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      API::V1::Defaults.expects(:log_error)
      Services::Promocode::AddToUser.stubs(:new).returns(service)
      service.stubs(:call).returns(service)
      service.stubs(:error).returns(Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_VALID)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal ['is invalid'], response_json['error']['details']['code']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'already used' do
      service   = mock()
      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      API::V1::Defaults.expects(:log_error)
      Services::Promocode::AddToUser.stubs(:new).returns(service)
      service.stubs(:call).returns(service)
      service.stubs(:error).returns(Services::Promocode::AddToUser::ERROR_PROMOCODE_ALREADY_USED)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal ['already used'], response_json['error']['details']['code']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'not added' do
      service   = mock()
      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      API::V1::Defaults.expects(:log_error)
      Services::Promocode::AddToUser.stubs(:new).returns(service)
      service.stubs(:call).returns(service)
      service.stubs(:error).returns(Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ADDED)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal 'The promo code was not applied', response_json['error']['details']
      assert_equal 'user_promocode_not_added', response_json['error']['type']
    end

    test 'added' do
      service   = mock()
      user      = create(:user)
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      Services::Promocode::AddToUser.stubs(:new).returns(service)
      service.stubs(:call).returns(service)
      service.stubs(:error).returns(nil)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/promocodes', {
        code: SecureRandom.hex(8)
      }

      assert_equal 201, response_status
      assert_equal 'null', last_response.body
    end
  end
end
