class Services::SystemInfo::Raised
  include TimeConcern

  ERROR_NOT_AUTHORIZED             = 'error_not_authorized'.freeze
  ERROR_INVALID_STARTING_AT_FORMAT = 'error_invalid_starting_at_format'.freeze
  ERROR_INVALID_ENDING_AT_FORMAT   = 'error_invalid_ending_at_format'.freeze

  attr_reader :error

  def initialize(params = {})
    @params            = params
    @parameters        = Parameter.get_all
    @authorization_key = @parameters['system.authorization_key']
    @dates             = { starting_at: nil, ending_at: nil }
  end

  def call
    check_authorization
    process_date
    collect_information
  rescue Services::SystemInfo::RaisedError => e
    @error = e.message
    nil
  end

  private

  def check_authorization
    if @authorization_key.present? && @authorization_key != @params[:authorization_key]
      raise Services::SystemInfo::RaisedError, ERROR_NOT_AUTHORIZED
    end
  end

  def process_date
    if @params[:starting_at].present?
      unless datetime_in_iso8601?(@params[:starting_at])
        raise Services::SystemInfo::RaisedError, ERROR_INVALID_STARTING_AT_FORMAT
      end
      @dates[:starting_at] = DateTime.iso8601(@params[:starting_at].to_s).in_time_zone
    end

    if @params[:ending_at].present?
      unless datetime_in_iso8601?(@params[:ending_at])
        raise Services::SystemInfo::RaisedError, ERROR_INVALID_ENDING_AT_FORMAT
      end
      @dates[:ending_at] = DateTime.iso8601(@params[:ending_at].to_s).in_time_zone
    end
  end

  def collect_information
    raised_info = Rails.cache.fetch(
      "api_controller_ico_raised_from_#{@dates[:starting_at]}_to_#{@dates[:ending_at]}",
      expires_in: 30.seconds
    ) do
      token_amount                         = Payment.calc_total_ico_currency_amount(@dates)
      balances                             = Payment.balances(@dates[:starting_at], @dates[:ending_at])
      balances[:balance_total]             = 0
      balances[:balance_referral_total]    = 0
      balances[:currencies].each do |currency_symbol, value|
        balances[:balance_total]          += Services::Coin::CurrencyToCurrencyConverter.new(
          value[:balance],
          currency_symbol,
          @parameters['coin.rate_currency']
        ).call
        balances[:balance_referral_total] += Services::Coin::CurrencyToCurrencyConverter.new(
          value[:referral_balance],
          currency_symbol,
          @parameters['coin.rate_currency']
        ).call
      end
      token_total_amount = Payment.date_ranges(@dates[:starting_at], @dates[:ending_at]).total_amount_tokens
      {
        balances: balances,
        token_amount: token_amount,
        token_total_amount: token_total_amount
      }
    end

    IcoRaisedFormatter.new(
      raised_info[:balances],
      raised_info[:token_amount],
      raised_info[:token_total_amount], @parameters
    ).view_data
  end
end