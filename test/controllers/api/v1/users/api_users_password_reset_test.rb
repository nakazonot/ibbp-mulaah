require 'test_helper'

class APIUsersPasswordResetTest < ActiveSupport::TestCase
  describe 'POST /api/users/passwords' do
    test 'correct params' do
      user              = create(:user)
      edit_password_uri = 'http://test.ru'

      User.any_instance.expects(:send_reset_password_instructions_from_api).with(edit_password_uri)

      post '/api/users/passwords', {
        email: user.email,
        edit_password_uri: edit_password_uri
      }

      assert_nil response_header['Authorization']
      assert_equal 200, response_status
    end

    test 'non-existent email' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/passwords', {
        email: "#{SecureRandom.hex(8)}.mail.ru"
      }

      assert_nil response_header['Authorization']
      assert_equal 404, response_status
      assert_equal 'Couldn\'t find User', response_json['error']['details']
      assert_equal 'not_found_error', response_json['error']['type']
    end

    test 'empty params' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/passwords'

      assert_nil response_header['Authorization']
      assert_equal 422, response_status
      assert_equal ['is missing'], response_json['error']['details']['email']
      assert_equal 'validation_error', response_json['error']['type']
    end
  end
end