require 'test_helper'

class APIKYCReadTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/kyc' do
    test 'unauthenticated' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/kyc'

      assert_equal 401, response_status
      assert_equal API::V1::Errors::Types::USER_UNAUTHENTICATED_ERROR, response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'kyc verification not exist' do
      user          = create(:user)
      token         = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/kyc'

      assert_equal 200, response_status
      assert_nil response_json
    end

    test 'kyc not enabled' do
      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(false)

      user          = create(:user)
      token         = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/kyc'

      assert_equal 403, response_status
      assert_equal API::V1::Errors::Types::NOT_AUTHORIZED_ERROR, response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'kyc enabled, record exist' do
      Parameter.stubs(:kyc_verification_enabled?).returns(true)

      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      token            = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/users/current/kyc'

      assert_equal 200, response_status
      assert_equal present(kyc_verification, API::V1::Entities::KycVerification), response_json
    end
  end
end
