require 'test_helper'

class APIUsersPromocodeActualTest < ActiveSupport::TestCase
  describe 'GET /api/users/current/promocodes/active' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      get '/api/users/current/promocodes/active'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'promocode not exist' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/promocodes/active'

      assert_equal 200, response_status
      assert_nil response_json['code']
    end

    test 'promocode exist' do
      user            = create(:user)
      promocode       = create(:promocode)
      user_promocode  = create(
        :promocodes_user,
        user: user,
        promocode: promocode,
        promocode_property: promocode.property
      )
      token     = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      PromocodesUser.stubs(:search_actual_promocode_by_user).returns(user_promocode)

      header('Authorization', "Bearer #{token}")

      get '/api/users/current/promocodes/active'

      assert_equal 200, response_status
      assert_equal promocode.code, response_json['code']
    end
  end
end
