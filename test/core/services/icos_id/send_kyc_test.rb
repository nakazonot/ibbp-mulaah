require 'test_helper'

class SendKycTest < ActiveSupport::TestCase
  describe Services::IcosId::SendKyc do
    test 'server error' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns(nil)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_SERVER_ERROR, send_kyc_service.error
    end

    test 'user not exist' do
      user             = create(:user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      User.stubs(:find_by).with(id: user.id).returns(nil)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_USER_NOT_EXIST, send_kyc_service.error
    end

    test 'authorization error' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'Please sign in for this method'}]
      })

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_AUTHORIZATION_ERROR, send_kyc_service.error
    end

    test 'user already verified' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'You can\'t to verify twice'}]
      })

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_ALREADY_VERIFIED, send_kyc_service.error
    end

    test 'kyc not exist' do
      api_wrapper_mock = mock
      user             = create(:user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_KYC_NOT_EXIST, send_kyc_service.error
    end

    test 'when send kyc not allowed' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user, status: KycStatusType::APPROVED)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_SEND_KYC_NOT_ALLOWED, send_kyc_service.error
    end

    test 'unknown error' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})
      api_response     = {
        'Status' => 'error',
        'Result' => [{'Message' => SecureRandom.hex}]
      }

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns(api_response)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_UNKNOWN, send_kyc_service.error
    end

    test 'error without result in response' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})
      api_response     = {
        'Status' => 'error'
      }

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns(api_response)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_UNKNOWN, send_kyc_service.error
    end

    test 'error without first element in result' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})
      api_response     = {
        'Status' => 'error',
        'Result' => SecureRandom.hex
      }

      Services::IcosId::SendKyc.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns(api_response)

      send_kyc_service.call

      assert_equal Services::IcosId::SendKyc::ERROR_ICOS_ID_UNKNOWN, send_kyc_service.error
    end

    test 'success' do
      api_wrapper_mock = mock
      user             = create(:user)
      kyc_verification = create(:kyc_verification_filled, user: user)
      send_kyc_service = Services::IcosId::SendKyc.new(user.id, {})
      api_response      = {
        'Status' => 'ok',
      }

      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:kyc_verify).returns(api_response)

      send_kyc_service.call

      assert_nil send_kyc_service.error
      assert_equal KycStatusType::IN_PROGRESS, kyc_verification.reload.status
    end
  end
end
