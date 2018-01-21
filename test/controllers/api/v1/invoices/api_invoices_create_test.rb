require 'test_helper'

class APIInvoiceCreateTest < ActiveSupport::TestCase
  describe 'POST /api/invoices' do
    test 'unauthorized' do
      API::V1::Defaults.expects(:log_error)

      post '/api/invoices'

      assert_equal 401, response_status
      assert_equal 'user_unauthenticated_error', response_json['error']['type']
      assert_equal 'You need to sign in or sign up before continuing.', response_json['error']['details']
    end

    test 'without params' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/invoices'

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is missing'], response_json['error']['details']['full_name']
      assert_equal ['is missing'], response_json['error']['details']['amount']
    end

    test 'incorrect amount' do
      API::V1::Defaults.expects(:log_error)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/invoices', {
        full_name: SecureRandom.hex(8),
        amount: SecureRandom.hex(8)
      }

      assert_equal 422, response_status
      assert_equal 'validation_error', response_json['error']['type']
      assert_equal ['is invalid'], response_json['error']['details']['amount']
    end

    test 'correct params, buy invoice not created' do
      API::V1::Defaults.expects(:log_error)

      invoice = mock
      service = mock

      Services::Invoiced::InvoiceCreator.stubs(:new).returns(service)
      service.stubs(:call).returns(invoice)
      invoice.stubs(:present?).returns(false)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/invoices', {
        full_name: SecureRandom.hex(8),
        amount: 10000
      }

      assert_equal 422, response_status
      assert_equal 'invoice_create_error', response_json['error']['type']
      assert_equal 'Can not generate invoice. Please try again later.', response_json['error']['details']
    end

    test 'correct params, invoice generated' do
      invoice = mock()
      service = mock()
      pdf_url = 'pdf_link'

      Services::Invoiced::InvoiceCreator.stubs(:new).returns(service)
      service.stubs(:call).returns(invoice)
      invoice.stubs(:present?).returns(true)
      invoice.stubs(:persisted?).returns(true)
      invoice.stubs(:pdf_url).returns(pdf_url)

      user  = create(:user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user)

      header('Authorization', "Bearer #{token}")
      post '/api/invoices', {
        full_name: SecureRandom.hex(8),
        amount: Parameter.get_all['invoiced.min_amount_for_transfer']
      }

      assert_equal 201, response_status
      assert_equal pdf_url, response_json['pdf_url']
    end
  end
end
