class ApiWrappers::IcosId
  require 'rest-client'
  include Concerns::Log::Logger

  BASE_URI = ENV['ICOS_ID_TEST_MODE'].to_i == 1 ? 'https://api-demo.icosid.com' : 'https://api.icosid.com'

  def initialize
    @api_key = ENV['ICOS_ID_API_KEY']
  end

  def get_account_by_email(email)
    params = {Email: email.downcase}

    response = RestClient::Request.execute(
      method: :get,
      url: "#{BASE_URI}/v1/apps/user-data",
      headers: {
        Authorization: @api_key,
        params: params
      }
    )

    result = JSON.parse response.body
    log_params_error(params.merge(action: __method__.to_s), result) unless result['Status'] == 'ok'
    result

  rescue RestClient::Exception => e
    log_error("RestClient Exception: #{e.message}")
    return nil
  end

  def create_account_by_email(data)
    params = {
      Email: data[:email].downcase,
      FirstName: data[:first_name],
      MiddleName: data[:middle_name],
      LastName: data[:last_name],
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{BASE_URI}/v1/apps/signup",
      headers: {
        Authorization: @api_key,
        params: params
      }
    )

    result = JSON.parse response.body
    log_params_error(params.merge(action: __method__.to_s), result) unless result['Status'] == 'ok'
    result

  rescue RestClient::Exception => e
    log_error("RestClient Exception: #{e.message}")
    return nil
  end

  def kyc_verify(data)
    params = {
      Email: data[:email].downcase,
      FirstName: data[:first_name],
      MiddleName: data[:middle_name],
      LastName: data[:last_name],
      Gender: data[:gender],
      Dob: data[:dob],
      Phone: data[:phone],
      Country: data[:country_code],
      State: data[:state],
      Citizenship: data[:citizenship],
      City: data[:city],
      Address: data[:address],
      DocumentNumber: data[:document_number],
      Documents: data[:documents],
      multipart: true,
    }

    response = RestClient.post(
      "#{BASE_URI}/v1/apps/verify",
      params,
      headers={ Authorization: @api_key}
    )

    result = JSON.parse response.body
    log_params_error({action: __method__.to_s, email: params[:Email]}, result) unless result['Status'] == 'ok'
    result

  rescue RestClient::Exception => e
    log_error("RestClient Exception: #{e.message}")
    return nil
  end
end