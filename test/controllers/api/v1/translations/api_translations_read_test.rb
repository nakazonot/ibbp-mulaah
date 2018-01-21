require 'test_helper'

class APITranslationsReadTest < ActiveSupport::TestCase
  describe 'GET /api/translations' do
    test 'unauthorized' do
      get '/api/translations'

      assert_equal 200, response_status
      assert_equal Translation.count, response_json.count
      assert_not_nil response_json.first['locale']
      assert_not_nil response_json.first['key']
      assert_not_nil response_json.first['value']
    end
  end
end
