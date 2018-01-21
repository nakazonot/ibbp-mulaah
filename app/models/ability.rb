class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.role == User::ROLE_SUPPORT
      can :administrate, :all
      can :read, [User, Payment, PaymentAddress]
      can :manage, ActiveAdmin::Page, name: "User transactions"
      can :manage, ActiveAdmin::Page, name: 'Dashboard'
    elsif user.role == User::ROLE_ADMIN_READ_ONLY
      can :administrate, :all
      can :read, [User, Payment, Parameter, Translation, Promocode, IcoStage, BonusPreference, PaymentAddress, UserParameter, LoyaltyProgram]
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :view_index, [User, Payment, PaymentAddress]
      if ENV['KYC_VERIFICATION_ENABLE'].to_i == 1
        can :read, KycPermission
      end
    elsif user.role == User::ROLE_ADMIN
      can :administrate, :all
      can [:crud], [IcoStage, Promocode, BonusPreference, UserParameter, LoyaltyProgram]
      can [:read, :update], [Translation]
      can [:read], [Payment, Parameter, PaymentAddress]
      can [:create, :read, :update], User
      can [:confirm], User do |u|
        !u.confirmed?
      end
      can [:destroy], User do |u|
        u.can_be_deleted?
      end
      can [:update], Parameter do |parameter|
        !parameter.is_readonly
      end
      if ENV['KYC_VERIFICATION_ENABLE'].to_i == 1
        can :crud, KycPermission
      end
      can :manage, ActiveAdmin::Page
      can :view_index, [User, Payment, PaymentAddress]
      can :sync_currencies, Parameter do |parameter| 
        parameter.name == Parameter::AVAILABLE_CURRENCIES_NAME
      end
    end

    can :ico_enabled, :ico do
      Parameter.ico_enabled
    end

    can :buy_tokens, :stage do
      Parameter.buy_token_enabled(user)
    end

    can :buy_tokens, :user_kyc do
      KycPermission.allowed_action?(user, KycPermission::PERMISSION_TYPE_TOKEN_BUY)
    end

    can :receive_tokens, :user_kyc do
      KycPermission.allowed_action?(user, KycPermission::PERMISSION_TYPE_TOKEN_RECEIVE)
    end

    can :make_deposits, :user_kyc do
      KycPermission.allowed_action?(user, KycPermission::PERMISSION_TYPE_MAKE_DEPOSIT)
    end

    can :make_deposits, :stage do
      Parameter.make_deposit_enabled?
    end

    can :ico_closed, :ico do
      !Parameter.ico_enabled
    end

    can :input, :eth_wallet do
      Parameter.eth_wallet_enabled?
    end

    can :input, :btc_wallet do
      Parameter.btc_wallet_enabled?
    end

    can :input, :kyc do
      Parameter.get_all['user.kyc_enabled'].to_b
    end

    can :show_ico_info, :user do
      !user.new_record?
    end

    can :show_timer, :user do
      IcoStage.ico_dates_valid? && IcoStage.order(:date_start).first.date_start > Time.current
    end

    can :sign_contract, BuyTokensContract do |contract|
      contract.user_id == user.id
    end

    can :require_user_name_input_on_sign_up, :user do
      Parameter.require_user_name_input_on_sign_up?
    end

    can :referral_system_enabled, :ico do
      Parameter.referral_system_enabled?
    end

    can :referral_system, :tokens do
      user.ability.can?(:referral_system_enabled, :ico) && Parameter.referral_system_type?('tokens')
    end

    can :referral_system, :balance do
      user.ability.can?(:referral_system_enabled, :ico) && Parameter.referral_system_type?('balance')
    end

    can :do_sign_up, :all do |c|
      ENV['REFERRAL_ALLOW_SIGN_UP_REFERRALS_ONLY'].to_i == 0 || (c[:referral].present? && User.find_by(referral_uuid: c[:referral]).present?)
    end

    can :promo_token_enabled, :ico do
      Promocode.promo_token_enabled?
    end
  end
end
