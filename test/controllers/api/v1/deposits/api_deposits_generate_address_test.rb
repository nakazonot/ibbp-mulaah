require 'test_helper'

class APIDepositsGenerateAddressTest < ActiveSupport::TestCase
  describe 'POST /api/deposits/payment_addresses/:currency' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      post '/api/deposits/payment_addresses'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'invalid currency' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/deposits/payment_addresses', {
        currency: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['currency']
    end

    test 'can not create address' do
      API::V1::Defaults.expects(:log_error)
      Services::Coin::PaymentSystemAddressGetter.stubs(:call).returns(nil)
      Services::Coin::PaymentSystemAddressGetter.any_instance.expects(:log_info)
      Services::Coin::PaymentSystemAddressGetter.any_instance.expects(:log_warn)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/deposits/payment_addresses', {
        currency: 'BTC'
      }

      assert_equal 409, response_status
      assert_equal 'deposit_address_create_error', response_json['error']['type']
      assert_equal 'Can not get payment address. Please try again', response_json['error']['details']
    end

    test 'successfully generated' do
      user            = create(:user)
      token           = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      payment_address = create(:payment_address_btc, user: user)

      Services::Coin::PaymentSystemAddressGetter.stubs(:call).returns(payment_address)

      header('Authorization', "Bearer #{token}")
      post '/api/deposits/payment_addresses', {
        currency: 'BTC'
      }

      assert_equal 201, response_status
      assert_equal payment_address.payment_address, response_json[payment_address.currency]['payment_address']
    end
  end
end
