require 'test_helper'

class APIContractsBuyTokensTest < ActiveSupport::TestCase
  describe 'POST /api/contracts/:id/buy_tokens' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      post 'api/contracts/0/buy_tokens'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.',response_json['error']['details']
    end

    test 'contract not exist' do
      API::V1::Defaults.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post 'api/contracts/0/buy_tokens'

      assert_equal 404, response_status
      assert_equal 'not_found_error', response_json['error']['type']
      assert_equal 'Couldn\'t find BuyTokensContract', response_json['error']['details']
    end

    test 'contract already signed' do
      API::V1::Defaults.expects(:log_error)
      Services::Coin::CoinCreator.any_instance.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      payment     = create(:payment_purchase_tokens, user: user)
      contract    = create(:buy_tokens_contract, user: user, payment: payment)

      header('Authorization', "Bearer #{token}")
      post "api/contracts/#{contract.id}/buy_tokens"

      assert_equal 409, response_status
      assert_equal 'contract_accept_error', response_json['error']['type']
      assert_equal 'Contract already accepted.', response_json['error']['details']
    end

    test 'contract successful signed' do
      Services::SystemInfo::RequestInfo.any_instance.stubs(:call).returns({})
      Services::Coin::CoinCreator.any_instance.expects(:log_info).twice

      user            = create(:user)
      token           = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      payment_balance = create(:payment_balance_btc, user: user)
      contract        = create(:buy_tokens_contract, user: user)

      header('Authorization', "Bearer #{token}")
      post "api/contracts/#{contract.id}/buy_tokens"

      assert_equal 201, response_status
    end

    test 'without access to sign contract' do
      API::V1::Defaults.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      contract    = create(:buy_tokens_contract)

      header('Authorization', "Bearer #{token}")
      post "api/contracts/#{contract.id}/buy_tokens"

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'no access to buy tokens' do
      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:buy_token_enabled).returns(false)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post 'api/contracts/0/buy_tokens'

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'no access to show ICO info' do
      API::V1::Defaults.expects(:log_error)

      user        = create(:user)
      token       = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      Ability.any_instance.stubs(:can?).with(:show_ico_info, :user).returns(false)

      header('Authorization', "Bearer #{token}")
      post 'api/contracts/0/buy_tokens'

      assert_equal 403, response_status
      assert_equal 'not_authorized_error', response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end
  end
end


