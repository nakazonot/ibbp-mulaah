require 'test_helper'

class APIParametersReadTest < ActiveSupport::TestCase
  describe 'GET /api/parameters' do
    test 'unauthorized' do
      get '/api/parameters'

      assert_equal 200, response_status
      assert_equal Parameter.available_currencies, response_json['available_currencies']
      assert_equal Parameter.get_all['coin.rate_currency'], response_json['coin.rate_currency']
    end
  end
end


