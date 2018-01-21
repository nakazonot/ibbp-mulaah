class CatchInvalidPercentEncodingError
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionController::BadRequest => exception
      if exception.message =~ /invalid \%\-encoding \(/
        error_output = "There was a problem with params"
        return [
          400, { "Content-Type" => "application/json" },
          [ { status: 400, error: error_output }.to_json ]
        ]
      else
        raise error
      end
    end
  end
end
