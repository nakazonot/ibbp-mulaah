class CpaPostback < ApplicationRecord
  ACTION_SIGN_UP             = 'sign_up'.freeze
  ACTION_DEPOSIT_FIRST       = 'deposit_first'.freeze
  ACTION_DEPOSIT_NON_FIRST   = 'deposit_non_first'.freeze
  ACTION_DEPOSIT             = 'deposit'.freeze
  ACTION_BUY_TOKEN_FIRST     = 'buy_token_first'.freeze
  ACTION_BUY_TOKEN_NON_FIRST = 'buy_token_non_first'.freeze
  ACTION_BUY_TOKEN           = 'buy_token'.freeze
end