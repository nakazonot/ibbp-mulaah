require 'test_helper'

class APIInfosReadAbilitiesTest < ActiveSupport::TestCase
  describe 'GET /api/infos/abilities' do
    test 'unauthorized' do
      get '/api/infos/abilities'

      assert_equal 200, response_status
      assert_not_nil response_json
    end
  end
end
