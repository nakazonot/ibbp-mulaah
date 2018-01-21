require 'test_helper'

class APIUsersSessionsProlongTest < ActiveSupport::TestCase
  describe 'PUT /api/users/sessions/prolong' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/sessions/prolong'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'with auth' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/sessions/prolong'

      assert_equal 200, response_status
      assert_includes response_header['Authorization'], 'Bearer'
      assert_equal present(user, API::V1::Entities::User), response_json

      header('Authorization', response_header['Authorization'])
      get '/api/users/current'

      assert_equal 200, response_status
    end
  end
end
