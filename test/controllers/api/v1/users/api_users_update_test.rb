require 'test_helper'

class APIUsersUnlockTest < ActiveSupport::TestCase
  describe 'PUT /api/users/current' do
    test 'without auth' do
      API::V1::Defaults.expects(:log_error)

      put '/api/users/current'

      assert_equal 401, response_status
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
    end

    test 'without params' do
      user   = create(:user)
      token  = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current'

      assert_equal 200, response_status
      assert_equal user.id, response_json['id']
    end

    test 'update only name' do
      user     = create(:user)
      name_new = 'test_name'
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', {
        name: 'test_name'
      }

      assert_equal 200, response_status
      assert_equal user.id, response_json['id']
      assert_equal name_new, response_json['name']
      assert_equal name_new, user.reload.name
    end

    test 'update middle and name' do
      user     = create(:user)
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params   = {
        middle_name: SecureRandom.hex,
        last_name: SecureRandom.hex
      }

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', params

      assert_equal 200, response_status
      assert_equal user.id, response_json['id']
      assert_equal response_json['middle_name'], params[:middle_name]
      assert_equal response_json['last_name'], params[:last_name]
    end

    test 'try update phone to incorrect' do
      API::V1::Defaults.expects(:log_error)

      user     = create(:user)
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', {
        phone: 0
      }

      assert_equal 422, response_status
      assert_equal ['must contain 5 to 19 digits'], response_json['error']['details']['phone']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'try update wallets to invalid' do
      API::V1::Defaults.expects(:log_error)

      user     = create(:user)
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', {
        btc_wallet: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal ['format is invalid'], response_json['error']['details']['btc_wallet']
      assert_equal 'validation_error', response_json['error']['type']
    end

    test 'try update wallets to valid' do
      user     = create(:user)
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      wallets  = {
        btc_wallet: '1EV5MNxHYD9kwgEtAj5KWjyEwZb2R8QSqo'
      }

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', wallets

      assert_equal 200, response_status
      assert_equal wallets[:btc_wallet], response_json['btc_wallet']
    end

    test 'try update wallets when they are not turned' do
      Parameter.stubs(:eth_wallet_enabled?).returns(false)
      Parameter.stubs(:btc_wallet_enabled?).returns(false)

      user     = create(:user)
      token    = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      wallets  = {
        eth_wallet: '0x00F3626e62b8E1414455b6bcd037ea05E51C8907',
        btc_wallet: '1EV5MNxHYD9kwgEtAj5KWjyEwZb2R8QSqo'
      }


      header('Authorization', "Bearer #{token}")
      put '/api/users/current', wallets

      assert_equal 200, response_status
      assert_nil response_json['eth_wallet']
      assert_nil response_json['btc_wallet']
      assert_nil user.reload.eth_wallet
      assert_nil user.reload.btc_wallet
    end

    test 'all params a correct' do
      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      user_params = { phone: '+79787550045', name: SecureRandom.hex }

      header('Authorization', "Bearer #{token}")
      put '/api/users/current', user_params

      assert_equal 200, response_status
      assert_equal user.id, response_json['id']
      assert_equal user_params[:name], response_json['name']
      assert_equal user_params[:phone], response_json['phone']
    end
  end
end
