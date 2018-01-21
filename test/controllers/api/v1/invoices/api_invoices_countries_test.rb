require 'test_helper'

class APIInvoiceCountriesTest < ActiveSupport::TestCase
  describe 'GET /api/invoices/countries' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      get '/api/invoices/countries'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'authorized' do
      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      get '/api/invoices/countries'

      assert_equal 200, response_status
      assert_equal ISO3166::Country.translations, response_json
    end
  end
end
