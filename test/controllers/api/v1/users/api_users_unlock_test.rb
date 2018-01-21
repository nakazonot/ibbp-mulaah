require 'test_helper'

class APIUsersUnlockTest < ActiveSupport::TestCase
  describe 'PUT /api/users/unlocks' do
    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/unlocks'

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['unlock_token']
      assert_equal 'validation_error', response_json['error']['type']
    end
  end

  test 'incorrect token' do
    API::V1::Defaults.expects(:log_error)

    put '/api/users/unlocks', {
      unlock_token: SecureRandom.hex(8)
    }

    assert_nil response_header['Authorization']
    assert_equal 422, response_status
    assert_equal ['is invalid'], response_json['error']['details']['unlock_token']
    assert_equal 'validation_error', response_json['error']['type']
  end

  test 'correct token' do
    User.any_instance.expects(:send_unlock_instructions)

    user = create(:user)
    user.lock_access!

    put '/api/users/unlocks', {
      unlock_token: user.set_unlock_token
    }

    assert_equal 200, response_status
    assert_nil response_header['Authorization']
    assert_nil user.reload.locked_at
  end
end
