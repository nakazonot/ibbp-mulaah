module ResponseHelpers
  def response_json
    last_response.body == 'null' ? nil : JSON.parse(last_response.body)
  end

  def response_header
    last_response.header
  end

  def response_status
    last_response.status
  end
end