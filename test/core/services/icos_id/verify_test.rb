require 'test_helper'

class VerifyTest < ActiveSupport::TestCase
  describe Services::IcosId::Verify do
    test 'user not exist' do
      user           = create(:user)
      verify_service = Services::IcosId::Verify.new(user.id, {})

      Services::IcosId::Verify.any_instance.expects(:log_error)
      User.stubs(:find_by).with(id: user.id).returns(nil)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_USER_NOT_EXIST, verify_service.error
    end

    test 'ICOS ID account existed, verified' do
      Services::IcosId::Verify.any_instance.expects(:log_error)

      user                     = create(:user)
      verify_service           = Services::IcosId::Verify.new(user.id, {})
      get_account_service_mock = mock
      icos_id_account_data     = {
        uid:                   Faker::Number.number(3),
        email:                 Faker::Internet.email,
        first_name:            Faker::Name.first_name,
        middle_name:           Faker::Name.prefix,
        last_name:             Faker::Name.last_name,
        phone:                 Faker::PhoneNumber.cell_phone,
        lang:                  Faker::Address.country_code,
        document_number:       Faker::Number.number(10),
        use_g2fa:              false,
        globalid_verify:       false,
        globalid_agent_verify: '',
        netki_status:          '',
        kyc_status:            KycStatusType::APPROVED,
        kyc_reason:            'comment',
        kyc_at:                '0001-01-01T00:00:00Z'
      }

      Services::IcosId::GetAccount.stubs(:new).returns(get_account_service_mock)
      get_account_service_mock.stubs(:call)
      get_account_service_mock.stubs(:error)
      get_account_service_mock.stubs(:data).returns(icos_id_account_data)

      # Services::IcosId::Verify.any_instance.expects(:log_error)
      # User.stubs(:find_by).with(id: user.id).returns(nil)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_ICOS_ID_ALREADY_VERIFIED, verify_service.error
    end

    test 'ICOS ID account existed, in progress' do
      Services::IcosId::Verify.any_instance.expects(:log_error)

      user                     = create(:user)
      verify_service           = Services::IcosId::Verify.new(user.id, {})
      get_account_service_mock = mock
      icos_id_account_data     = {
        uid:                   Faker::Number.number(3),
        email:                 Faker::Internet.email,
        first_name:            Faker::Name.first_name,
        middle_name:           Faker::Name.prefix,
        last_name:             Faker::Name.last_name,
        phone:                 Faker::PhoneNumber.cell_phone,
        lang:                  Faker::Address.country_code,
        document_number:       Faker::Number.number(10),
        use_g2fa:              false,
        globalid_verify:       false,
        globalid_agent_verify: '',
        netki_status:          '',
        kyc_status:            'in_work',
        kyc_reason:            'comment',
        kyc_at:                '0001-01-01T00:00:00Z'
      }

      Services::IcosId::GetAccount.stubs(:new).returns(get_account_service_mock)
      get_account_service_mock.stubs(:call)
      get_account_service_mock.stubs(:error)
      get_account_service_mock.stubs(:data).returns(icos_id_account_data)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_ICOS_ID_VERIFY_IN_PROGRESS, verify_service.error
    end


    test 'Error while getting ICOS ID account' do
      Services::IcosId::Verify.any_instance.expects(:log_error)

      user                     = create(:user)
      verify_service           = Services::IcosId::Verify.new(user.id, {})
      get_account_service_mock = mock

      Services::IcosId::GetAccount.stubs(:new).returns(get_account_service_mock)
      get_account_service_mock.stubs(:call)
      get_account_service_mock.stubs(:error).returns(Services::IcosId::GetAccount::ERROR_ICOS_ID_UNKNOWN)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_GET_ICOS_ID_ACCOUNT, verify_service.error
    end


    test 'Error while creating ICOS ID account' do
      Services::IcosId::Verify.any_instance.expects(:log_error)

      user                        = create(:user)
      verify_service              = Services::IcosId::Verify.new(user.id, {})
      get_account_service_mock    = mock
      create_account_service_mock = mock

      Services::IcosId::GetAccount.stubs(:new).returns(get_account_service_mock)
      Services::IcosId::CreateAccount.stubs(:new).returns(create_account_service_mock)
      get_account_service_mock.stubs(:call)
      get_account_service_mock.stubs(:error).returns(Services::IcosId::GetAccount::ERROR_ICOS_ID_USER_NOT_EXIST)
      create_account_service_mock.stubs(:call)
      create_account_service_mock.stubs(:error).returns(Services::IcosId::CreateAccount::ERROR_ICOS_ID_SERVER_ERROR)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_CREATE_ICOS_ID_ACCOUNT, verify_service.error
    end

    test 'error while sending KYC verify' do
      Services::IcosId::Verify.any_instance.expects(:log_error)

      user                        = create(:user)
      verify_service              = Services::IcosId::Verify.new(user.id, {})
      get_account_service_mock    = mock
      create_account_service_mock = mock
      send_kyc_service_mock       = mock

      Services::IcosId::GetAccount.stubs(:new).returns(get_account_service_mock)
      Services::IcosId::CreateAccount.stubs(:new).returns(create_account_service_mock)
      Services::IcosId::SendKyc.stubs(:new).returns(send_kyc_service_mock)
      get_account_service_mock.stubs(:call)
      get_account_service_mock.stubs(:error).returns(Services::IcosId::GetAccount::ERROR_ICOS_ID_USER_NOT_EXIST)
      create_account_service_mock.stubs(:call)
      create_account_service_mock.stubs(:error).returns(nil)
      send_kyc_service_mock.stubs(:call)
      send_kyc_service_mock.stubs(:error).returns(Services::IcosId::SendKyc::ERROR_ICOS_ID_SERVER_ERROR)

      verify_service.call

      assert_equal Services::IcosId::Verify::ERROR_SEND_VERIFY, verify_service.error
    end
  end
end
