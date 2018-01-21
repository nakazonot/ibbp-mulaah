require 'test_helper'

class APIDepositsReadGeneratedAddressesTest < ActiveSupport::TestCase
  describe 'GET /api/deposits/payment_addresses' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/deposits/payment_addresses'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'successfully' do
      user                = create(:user)
      token               = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      payment_address_btc = create(:payment_address_btc, user: user)
      payment_address_xrp = create(:payment_address_xrp, user: user)

      header('Authorization', "Bearer #{token}")
      get '/api/deposits/payment_addresses'

      assert_equal 200, response_status
      assert_equal payment_address_btc.payment_address, response_json['BTC']['payment_address']
      assert_equal payment_address_xrp.payment_address, response_json['XRP']['payment_address']
      assert_equal payment_address_xrp.dest_tag, response_json['XRP']['dest_tag']
      assert_nil response_json['DASH']
    end
  end
end
