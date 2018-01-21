require 'test_helper'

class APIInfosReadRaisedTest < ActiveSupport::TestCase
  describe 'GET /api/infos/raised' do
    test 'authorization not enabled' do
      get '/api/infos/raised'

      assert_equal 200, response_status
      assert_not_nil response_json['deposit']
      assert_not_nil response_json['referral_balance']
      assert_not_nil response_json['tokens']
    end

    test 'unauthorized, authorization enabled' do
      API::V1::Defaults.expects(:log_error)

      authorization_key = SecureRandom.hex
      Parameter.find_by(name: 'system.authorization_key').update_column(:value, authorization_key)

      get '/api/infos/raised'

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'authorized, authorization enabled' do
      authorization_key = SecureRandom.hex
      Parameter.find_by(name: 'system.authorization_key').update_column(:value, authorization_key)

      get '/api/infos/raised', {
        authorization_key: authorization_key
      }

      assert_equal 200, response_status
      assert_not_nil response_json['deposit']
      assert_not_nil response_json['referral_balance']
      assert_not_nil response_json['tokens']
    end

    test 'with correct starting_at' do
      user = create(:user)
      create(:payment_balance_eth, user: user, amount_buyer: 32, created_at: (Time.now + 1.year + 1.day).iso8601)
      create(:payment_balance_btc, user: user, amount_buyer: 64)
      create(:payment_balance_usd, user: user, amount_buyer: 128)

      get '/api/infos/raised', {
        starting_at: (Time.now + 1.year).iso8601.to_s
      }

      assert_equal 200, response_status
      assert_equal 32.0, response_json['deposit']['ETH']
      assert_equal 0.0, response_json['referral_balance']['total']
      assert_equal 0.0, response_json['tokens']['total']
    end

    test 'with incorrect starting_at' do
      API::V1::Defaults.expects(:log_error)

      user = create(:user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_usd, user: user)

      get '/api/infos/raised', {
        starting_at: SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['starting_at']
    end

    test 'with incorrect starting_at and ending_at' do
      API::V1::Defaults.expects(:log_error)

      user = create(:user)
      create(:payment_balance_eth, user: user)
      create(:payment_balance_btc, user: user)
      create(:payment_balance_usd, user: user)

      get '/api/infos/raised', {
        starting_at: SecureRandom.hex,
        ending_at:   SecureRandom.hex
      }

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['starting_at']
      assert_equal ['is invalid'], response_json['error']['details']['ending_at']
    end
  end
end
