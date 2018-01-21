require 'test_helper'

class CreateAccountTest < ActiveSupport::TestCase
  describe Services::IcosId::CreateAccount do
    test 'server error' do
      api_wrapper_mock       = mock
      user                   = create(:user)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns(nil)

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_SERVER_ERROR, create_account_service.error
    end

    test 'user not exist' do
      user                   = create(:user,)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      User.stubs(:find_by).with(id: user.id).returns(nil)

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_USER_NOT_EXIST, create_account_service.error
    end

    test 'authorization error' do
      api_wrapper_mock       = mock
      user                   = create(
        :user,
        name:        Faker::Name.first_name,
        middle_name: Faker::Name.prefix,
        last_name:   Faker::Name.last_name
      )
      create_account_service = Services::IcosId::CreateAccount.new(user.id)

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'Please sign in for this method'}]
      })

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_AUTHORIZATION_ERROR, create_account_service.error
    end

    test 'user already exist' do
      api_wrapper_mock       = mock
      user                   = create(
        :user,
        name:        Faker::Name.first_name,
        middle_name: Faker::Name.prefix,
        last_name:   Faker::Name.last_name
      )
      create_account_service = Services::IcosId::CreateAccount.new(user.id)

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'This email address has already been taken.'}]
      })

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_EMAIL_ALREADY_TAKEN, create_account_service.error
    end

    test 'unknown error' do
      api_wrapper_mock       = mock
      user                   = create(:user)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)
      api_response           = {
        'Status' => 'error',
        'Result' => [{'Message' => SecureRandom.hex}]
      }

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns(api_response)

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_UNKNOWN, create_account_service.error
    end

    test 'error without result in response' do
      api_wrapper_mock       = mock
      user                   = create(:user)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)
      api_response           = {
        'Status' => 'error'
      }

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns(api_response)

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_UNKNOWN, create_account_service.error
    end


    test 'error without first element in result' do
      api_wrapper_mock       = mock
      user                   = create(:user)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)
      api_response           = {
        'Status' => 'error',
        'Result' => SecureRandom.hex
      }

      Services::IcosId::CreateAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns(api_response)

      create_account_service.call

      assert_equal Services::IcosId::CreateAccount::ERROR_ICOS_ID_UNKNOWN, create_account_service.error
    end

    test 'success' do
      api_wrapper_mock       = mock
      kyc_mailer_mock        = mock
      user                   = create(:user)
      create_account_service = Services::IcosId::CreateAccount.new(user.id)
      api_response           = {
        'Status' => 'ok',
      }

      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:create_account_by_email).returns(api_response)
      KycMailer.stubs(:message_created_icos_id_account_notification).returns(kyc_mailer_mock)
      kyc_mailer_mock.expects(:deliver_later)

      create_account_service.call

      assert_nil create_account_service.error
    end
  end
end
