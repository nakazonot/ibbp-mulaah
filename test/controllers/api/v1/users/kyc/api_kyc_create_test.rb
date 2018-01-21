require 'test_helper'

class APIKYCCreateTest < ActiveSupport::TestCase
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

  describe 'POST /api/users/current/kyc' do
    test 'unauthenticated' do
      API::V1::Defaults.expects(:log_error)

      post '/api/users/current/kyc'

      assert_equal 401, response_status
      assert_equal API::V1::Errors::Types::USER_UNAUTHENTICATED_ERROR, response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'kyc not enabled' do
      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(false)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params = prepare_kyc_params

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 403, response_status
      assert_equal API::V1::Errors::Types::NOT_AUTHORIZED_ERROR, response_json['error']['type']
      assert_equal 'Don\'t have permission to access this resource', response_json['error']['details']
    end

    test 'when user not exist' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_USER_NOT_EXIST)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 404, response_status
      assert_equal API::V1::Errors::Types::NOT_FOUND_ERROR, response_json['error']['type']
      assert_equal 'User does not exist.', response_json['error']['details']
    end

    test 'when can not get ICOS ID account information' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_GET_ICOS_ID_ACCOUNT)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 409, response_status
      assert_equal API::V1::Errors::Types::ICOS_ID_GET_ACCOUNT_ERROR, response_json['error']['type']
      assert_equal 'Can not get ICOS ID account.', response_json['error']['details']
    end

    test 'when can not create ICOS ID account' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_CREATE_ICOS_ID_ACCOUNT)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 409, response_status
      assert_equal API::V1::Errors::Types::ICOS_ID_CREATE_ACCOUNT_ERROR, response_json['error']['type']
      assert_equal 'Can not create ICOS ID account.', response_json['error']['details']
    end

    test 'when can send KYC verify to ICOS ID' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_SEND_VERIFY)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 409, response_status
      assert_equal API::V1::Errors::Types::ICOS_ID_SEND_VERIFY_ERROR, response_json['error']['type']
      assert_equal 'Can not send verify KYC to ICOS ID.', response_json['error']['details']
    end

    test 'when KYC already verified' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_ICOS_ID_ALREADY_VERIFIED)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 409, response_status
      assert_equal API::V1::Errors::Types::ICOS_ID_ALREADY_VERIFIED_ERROR, response_json['error']['type']
      assert_equal 'User already verified.', response_json['error']['details']
    end

    test 'when previous KYC verify still in processing' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      API::V1::Defaults.expects(:log_error)
      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(Services::IcosId::Verify::ERROR_ICOS_ID_VERIFY_IN_PROGRESS)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 409, response_status
      assert_equal API::V1::Errors::Types::ICOS_ID_VERIFY_IN_PROGRESS_ERROR, response_json['error']['type']
      assert_equal 'Previous KYC verify still in processing.', response_json['error']['details']
    end

    test 'without error' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock

      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(nil)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 201, response_status
      assert_nil response_json
    end

    test 'success' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params
      kyc_verify_service_mock = mock
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
          'GlobalidAgentVerify' => SecureRandom.hex,
          'NetkiStatus'         => SecureRandom.hex,
          'KycStatus'           => 'in_work',
          'KycReason'           => 'comment',
          'KycAt'               => '0001-01-01T00:00:00Z'
        }
      }
      expected_data = {
        uid:   api_response['Result']['Id'],
        email: api_response['Result']['Email'],
        first_name: api_response['Result']['FirstName'],
        middle_name: api_response['Result']['MiddleName'],
        last_name: api_response['Result']['LastName'],
        phone: api_response['Result']['Phone'],
        lang: api_response['Result']['Lang'],
        document_number: api_response['Result']['DocumentNumber'],
        use_g2fa: api_response['Result']['UseG2fa'],
        globalid_verify: api_response['Result']['GlobalidVerify'],
        globalid_agent_verify: api_response['Result']['GlobalidAgentVerify'],
        netki_status: api_response['Result']['NetkiStatus'],
        kyc_status: api_response['Result']['KycStatus'],
        kyc_reason: api_response['Result']['KycReason'],
        kyc_at: api_response['Result']['KycAt']
      }

      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Services::IcosId::Verify.stubs(:new).returns(kyc_verify_service_mock)
      kyc_verify_service_mock.stubs(:call)
      kyc_verify_service_mock.stubs(:error).returns(nil)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 201, response_status
      assert_nil response_json
    end

    test 'too large file' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params

      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      Parameter.stubs(:kyc_max_file_size).returns(0.1)
      API::V1::Defaults.expects(:log_error)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['too large file size, maximum allowed 0.1 MB'], response_json['error']['details']['document_front']
      assert_equal ['too large file size, maximum allowed 0.1 MB'], response_json['error']['details']['document_selfie']
    end

    test 'invalid file format' do
      user                    = create(:user)
      token                   = Warden::JWTAuth::UserEncoder.new.call(user, :user)
      params                  = prepare_kyc_params.merge({
        document_front: Rack::Test::UploadedFile.new(
          Rails.root.join('test', 'fixtures', 'files', 'test.txt'),
          'text/plain'
        )
      })

      Parameter.stubs(:kyc_verification_enabled?).returns(true)
      API::V1::Defaults.expects(:log_error)

      header('Authorization', "Bearer #{token}")
      post '/api/users/current/kyc', params

      assert_equal 422, response_status
      assert_equal API::V1::Errors::Types::VALIDATION_ERROR, response_json['error']['type']
      assert_equal ['invalid file format'], response_json['error']['details']['document_front']
    end
  end
end
