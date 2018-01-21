require 'test_helper'

class GetAccountTest < ActiveSupport::TestCase
  def prepare_kyc_params
    kyc_attributes = build(:kyc_verification_filled).kyc

    {
      phone:          kyc_attributes[:phone],
      first_name:     kyc_attributes[:first_name],
      middle_name:    kyc_attributes[:middle_name],
      last_name:      kyc_attributes[:last_name],
      address_line_1: kyc_attributes[:address][:address_line_1],
      address_line_2: kyc_attributes[:address][:address_line_2],
      address_line_3: kyc_attributes[:address][:address_line_3],
      country_code:   kyc_attributes[:country_code],
      city:           kyc_attributes[:city],
      state:          kyc_attributes[:state],
      citizenship:    kyc_attributes[:citizenship],
      gender:         kyc_attributes[:gender],
      dob:            kyc_attributes[:dob],
      document_front: Rack::Test::UploadedFile.new(
        Rails.root.join('test', 'fixtures', 'files', 'test.jpg'),
        'image/jpeg'
      ),
      document_selfie: Rack::Test::UploadedFile.new(
        Rails.root.join('test', 'fixtures', 'files', 'test.jpg'),
        'image/jpeg'
      )
    }
  end

  describe Services::IcosId::GetAccount do
    test 'server error' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns(nil)

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_SERVER_ERROR, get_account_service.error
    end

    test 'user not exist' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'Client not found'}]
      })

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_USER_NOT_EXIST, get_account_service.error
    end

    test 'authorization error' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns({
        'Status' => 'error',
        'Result' => [{'Message' => 'Please sign in for this method'}]
      })

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_AUTHORIZATION_ERROR, get_account_service.error
    end

    test 'unknown error' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)
      api_response        = {
        'Status' => 'error',
        'Result' => [{'Message' => SecureRandom.hex}]
      }

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns(api_response)

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_UNKNOWN, get_account_service.error
    end

    test 'error without result in response' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)
      api_response        = {
        'Status' => 'error'
      }

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns(api_response)

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_UNKNOWN, get_account_service.error
    end


    test 'error without first element in result' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)
      api_response        = {
        'Status' => 'error',
        'Result' => SecureRandom.hex
      }

      Services::IcosId::GetAccount.any_instance.expects(:log_error)
      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns(api_response)

      get_account_service.call

      assert_equal Services::IcosId::GetAccount::ERROR_ICOS_ID_UNKNOWN, get_account_service.error
    end

    test 'success' do
      api_wrapper_mock    = mock
      user                = create(:user)
      get_account_service = Services::IcosId::GetAccount.new(user.email)
      api_response = {
        'Status' => 'ok',
        'Result' => {
          'Id'                  => Faker::Number.number(3),
          'Email'               => Faker::Internet.email,
          'FirstName'           => Faker::Name.first_name,
          'MiddleName'          => Faker::Name.prefix,
          'LastName'            => Faker::Name.last_name,
          'Phone'               => Faker::PhoneNumber.cell_phone,
          'Lang'                => Faker::Address.country_code,
          'DocumentNumber'      => Faker::Number.number(10),
          'UseG2fa'             => false,
          'GlobalidVerify'      => false,
          'GlobalidAgentVerify' => '',
          'NetkiStatus'         => '',
          'KycStatus'           => 'in_work',
          'KycReason'           => 'comment',
          'KycAt'               => '0001-01-01T00:00:00Z'
        }
      }
      expected_data = {
        uid:                   api_response['Result']['Id'],
        email:                 api_response['Result']['Email'],
        first_name:            api_response['Result']['FirstName'],
        middle_name:           api_response['Result']['MiddleName'],
        last_name:             api_response['Result']['LastName'],
        phone:                 api_response['Result']['Phone'],
        lang:                  api_response['Result']['Lang'],
        document_number:       api_response['Result']['DocumentNumber'],
        use_g2fa:              api_response['Result']['UseG2fa'],
        globalid_verify:       api_response['Result']['GlobalidVerify'],
        globalid_agent_verify: api_response['Result']['GlobalidAgentVerify'],
        netki_status:          api_response['Result']['NetkiStatus'],
        kyc_status:            api_response['Result']['KycStatus'],
        kyc_reason:            api_response['Result']['KycReason'],
        kyc_at:                api_response['Result']['KycAt']
      }

      ApiWrappers::IcosId.stubs(:new).returns(api_wrapper_mock)
      api_wrapper_mock.stubs(:get_account_by_email).with(user.email).returns(api_response)

      get_account_service.call

      assert_nil get_account_service.error
      assert_equal expected_data, get_account_service.data
    end
  end
end
