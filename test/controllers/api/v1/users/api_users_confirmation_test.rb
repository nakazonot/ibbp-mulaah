require 'test_helper'

class APIUsersConfirmationTest < ActiveSupport::TestCase
  describe 'PUT /api/users/confirmations' do
    test 'correct params' do
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
      User.any_instance.expects(:send_confirmation_instructions)

      user = create(:user, confirmed_at: nil)

      put '/api/users/confirmations', {
        confirmation_token: user.confirmation_token
      }

      assert_equal 200, response_status
      assert_nil response_header['Authorization']
      assert_not_nil response_json['id']
      assert_not_nil user.reload.confirmed_at
      assert_equal user, User.find(response_json['id'])
    end

    test 'try confirmed twice' do
      API::V1::Defaults.expects(:log_error)
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
      User.any_instance.expects(:send_confirmation_instructions)

      user = create(:user, confirmed_at: nil)

      put '/api/users/confirmations', { confirmation_token: user.confirmation_token }
      put '/api/users/confirmations', { confirmation_token: user.confirmation_token }

      assert_equal 422, response_status
      assert_nil response_header['Authorization']
      assert_equal ['was already confirmed, please try signing in'], response_json['error']['details']['email']
      assert_equal 'validation_error', response_json['error']['type']
      assert_not_nil user.reload.confirmed_at
    end

    test 'invalid token' do
      API::V1::Defaults.expects(:log_error)
      ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
      ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
      User.any_instance.expects(:send_confirmation_instructions)

      user = create(:user, confirmed_at: nil)

      put '/api/users/confirmations', { confirmation_token: SecureRandom.hex(8) }

      assert_equal 422, response_status
      assert_nil response_header['Authorization']
      assert_equal ['is invalid'], response_json['error']['details']['confirmation_token']
      assert_equal 'validation_error', response_json['error']['type']
      assert_nil user.reload.confirmed_at
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/confirmations', {
        confirmation_token: 'test'
      }

      assert_equal 422, response_status
      assert_nil response_header['Authorization']
      assert_equal ['is invalid'], response_json['error']['details']['confirmation_token']
      assert_equal 'validation_error', response_json['error']['type']
    end
  end
end
