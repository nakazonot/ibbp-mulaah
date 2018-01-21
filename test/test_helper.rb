ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'
require 'minitest/rails'
require 'minitest/reporters'
require 'rack/test'
require 'helpers/ResponseHelpers'
require 'helpers/EntityHelpers'
require 'mocha/mini_test'

Minitest::Reporters.use!
FactoryGirl.find_definitions

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Rack::Test::Methods
  include Warden::Test::Mock
  include ResponseHelpers
  include EntityHelpers

  def app
    Rails.application
  end

  def setup
    header('Accept', 'application/json')

    init_ico_stage
    init_system_settings
    init_exchange_rate

    SendItemToGoogleAnalyticsJob.stubs(:perform_later)
    SendTransactionToGoogleAnalyticsJob.stubs(:perform_later)
    Rails.cache.clear
  end

  def init_system_settings
    parameters = {
      'coin.tiker': 'ICO',
      'available_currencies': {
        'BTC':  { 'name': 'Bitcoin' },
        'LTC':  { 'name': 'Litecoin' },
        'XRP':  { 'name': 'Ripple' },
        'DASH': { 'name': 'Dash' },
        'ETC':  { 'name': 'Ether Classic' },
        'ETH':  { 'name': 'Ether' }
      }.to_json,
      'user.referral_bonus_percent':      '10',
      'coin.investments_volume':          '100000000',
      'coin.rate_currency':               'BTC',
      'coin.precision':                   '2',
      'coin.currency_precision':          '4',
      'invoiced.min_amount_for_transfer': '1000',
      'invoiced.max_amount_for_transfer': '10000000',
      'system.btc_wallet_enabled':        '1'
    }

    Parameter.where(name: parameters.keys).each do |parameter|
      parameter.update_column(:value, parameters[parameter.name.to_sym])
    end
  end

  def init_exchange_rate
    exchange_rates = [
      { from: 'BTC',  to: 'BTC', rate: 1        },
      { from: 'LTC',  to: 'BTC', rate: 0.0104   },
      { from: 'XRP',  to: 'BTC', rate: 0.000051 },
      { from: 'DASH', to: 'BTC', rate: 0.057479 },
      { from: 'ETC',  to: 'BTC', rate: 0.002264 },
      { from: 'ETH',  to: 'BTC', rate: 0.06009  },
      { from: 'USD',  to: 'BTC', rate: 0.00019  },
    ]

    exchange_rates.map { |exchange_rate| create(:exchange_rate, exchange_rate) }
  end

  def init_ico_stage
    create(:bonus_preference_current_stage_zero, ico_stage: create(:ico_stage_current))
  end
end
