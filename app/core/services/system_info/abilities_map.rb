class Services::SystemInfo::AbilitiesMap
  attr_reader :map, :user

  def initialize(user_id = nil)
    @user = user_id.present? ? User.find(user_id) : User.new
  end

  def call
    @map = generate_abilities_map
  end

  private

  def generate_abilities_map
    {
      can_be_used_promo_token:     @user.ability.can?(:promo_token_enabled, :ico),
      can_input_eth_wallet:        @user.ability.can?(:input, :eth_wallet),
      can_input_btc_wallet:        @user.ability.can?(:input, :btc_wallet),
      can_require_name_on_sign_up: @user.ability.can?(:require_user_name_input_on_sign_up, :user),
      can_show_ico_info:           @user.ability.can?(:show_ico_info, :user),
      can_show_timer:              @user.ability.can?(:show_timer, :user),
      can_user_buy_tokens:         @user.ability.can?(:buy_tokens, :stage) && @user.ability.can?(:buy_tokens, :user_kyc),
      can_user_receive_tokens:     @user.ability.can?(:receive_tokens, :user_kyc),
      can_user_make_deposits:      @user.ability.can?(:make_deposits, :stage) && @user.ability.can?(:make_deposits, :user_kyc),
      can_user_sign_up:            @user.ability.can?(:do_sign_up, :all),
    }
  end
end
