require 'test_helper'

class APIInfosReadSystemTest < ActiveSupport::TestCase
  describe 'GET /api/infos/system' do
    test 'authorization not enabled' do
      get '/api/infos/system'

      assert_equal 200, response_status
      assert_not_nil response_json['current_stage_id']
      assert_not_nil response_json['currency']
      assert_not_nil response_json['ico_stages']
    end

    test 'unauthorized, authorization enabled' do
      API::V1::Defaults.expects(:log_error)

      authorization_key = SecureRandom.hex
      Parameter.find_by(name: 'system.authorization_key').update_column(:value, authorization_key)

      get '/api/infos/system'

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'authorized, authorization enabled' do
      authorization_key = SecureRandom.hex
      Parameter.find_by(name: 'system.authorization_key').update_column(:value, authorization_key)

      get '/api/infos/system', {
        authorization_key: authorization_key
      }

      assert_equal 200, response_status
      assert_not_nil response_json['current_stage_id']
      assert_not_nil response_json['currency']
      assert_not_nil response_json['ico_stages']
    end

    test 'ico not enabled' do
      API::V1::Defaults.expects(:log_error)

      Parameter.stubs(:ico_enabled).returns(false)

      get '/api/infos/system'

      assert_equal 403, response_status
      assert_equal 'ico_closed_error', response_json['error']['type']
      assert_not_nil response_json['error']['details']['ico_stages']
    end
  end
end
