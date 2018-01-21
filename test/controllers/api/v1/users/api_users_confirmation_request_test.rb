require 'test_helper'

class APIUsersConfirmationRequestTest < ActiveSupport::TestCase
  before :all do
    ENV.stubs(:[]).with('KYC_VERIFICATION_ENABLE').returns('0')
    ENV.stubs(:[]).with('SKIP_USER_CONFIRMATION').returns('0')
  end

  describe 'POST /api/users/confirmations' do
    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/confirmations'

      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['email']
      assert_equal 'validation_error', response_json['error']['type']
    end
  end

  test 'un-existed email' do
    API::V1::Defaults.expects(:log_error)

    post '/api/users/confirmations', {
      email: SecureRandom.hex(8)
    }

    assert_equal 422, response_status
    assert_equal ['not found'], response_json['error']['details']['email']
    assert_equal 'validation_error', response_json['error']['type']
  end

  test 'existed email, but already confirmed' do
    API::V1::Defaults.expects(:log_error)

    user = create(:user)

    post '/api/users/confirmations', {
      email: user.email
    }

    assert_equal 422, response_status
    assert_equal ['was already confirmed, please try signing in'], response_json['error']['details']['email']
    assert_equal 'validation_error', response_json['error']['type']
  end

  test 'existed email, not confirmed' do
    User.any_instance.expects(:send_confirmation_notification_from_api)
    User.any_instance.expects(:send_confirmation_instructions)

    user = create(:user, confirmed_at: nil)

    post '/api/users/confirmations', {
      email: user.email
    }

    assert_equal 200, response_status
  end
end
