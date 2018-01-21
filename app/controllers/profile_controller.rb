class ProfileController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_action :authenticate_user!

  def edit
    prepare_for_view
  end

  def update
    prepare_for_view
    current_user.validated_scopes  = [:phone_require, :name_require, :eth_wallet_require, :btc_wallet_require]

    if params[:user].present? && current_user.update(user_params)
      flash[:notice] = 'You have successfully updated your profile'
    end
    render :edit
  end

  def agreement
    return ajax_error(error: 'You alredy accepted license agreement') if current_user.agreement
    current_user.update_column(:agreement, true)
    ajax_ok
  end

  def payments
    payments_scope = Payment.by_user(current_user.id).not_system
    payments_scope = Payment.scope_by_type(params[:filter_type], payments_scope) if params[:filter_type].present?

    @payment_types = payments_scope.distinct(:payment_type).pluck(:payment_type)
    @payments      = smart_listing_create(:payments, payments_scope, partial: "profile/list", default_sort: {created_at: "desc"})
  end

  def ajax_add_promocode
    add_promocode_service = Services::Promocode::AddToUser.new(current_user, params[:promocode]).call

    case add_promocode_service.error
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_EXIST
      ajax_error({ msg: t('promocode.not_exist') })
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_VALID
      ajax_error({ msg: t('promocode.not_valid') })
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ACTUAL
      ajax_error({ msg: t('promocode.not_actual') })
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ADDED
      ajax_error({ msg: t('promocode.not_added') })
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_ALREADY_USED
      ajax_error({ msg: t('promocode.already_used')})
    when Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ENOUGH_PROMO_TOKENS
      ajax_error({ msg: t('promocode.promotoken.not_enough_promo_tokens')})
    else
      flash[:notice] = t('promocode.added') if add_promocode_service.is_buy_tokens_promocode
      ajax_ok({
        msg: t('promocode.added'),
        type: add_promocode_service.promocode.discount_type,
        buy_tokens_promocode: add_promocode_service.is_buy_tokens_promocode
      })
    end
  end

  def ajax_get_promocode
    user_promocode  = PromocodesUser.search_actual_promocode_by_user(current_user)
    code            = user_promocode.present? ? user_promocode.promocode.code : nil

    ajax_ok({ code: code })
  end

  def ajax_get_promo_token_address
    authorize!(:show_ico_info, :user)
    authorize!(:promo_token_enabled, :ico)
    address = Services::PaymentAddress::PromoTokensAddressGetter.new(user: current_user).call
    return ajax_error(error: I18n.t('payment_address.promo_tokens.can_not_get_address')) if address.nil?
    ajax_ok({ address: address.payment_address })
  end

  def change_password
    return ajax_error({ msg: 'You must set a password before this action.' }) if current_user.uses_default_password

    if current_user.update_with_password(change_password_params)
      bypass_sign_in(current_user)
      return ajax_ok({ code: 'ok' })
    end

    ajax_error({error: 'valid_error', messages: current_user.errors.full_messages })
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :eth_wallet, :btc_wallet, :otp_required_for_login, :promocode)
  end

  def change_password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  def referrals_for_smart_listing
    return nil unless can? :referral_system_enabled, :ico
    return smart_listing_create(:referrals, User.referrals_with_bounty(current_user.id), partial: "profile/referrals_list", array: true) if can? :referral_system, :tokens
    return smart_listing_create(:referrals,
      ReferralsBountyBalanceFormatter.new(User.referrals_with_bounty_for_balance(current_user.id)).view_data,
      partial: "profile/referrals_balance_list",
      array: true) if can? :referral_system, :balance

    nil
  end

  def prepare_for_view
    @promo_token = Promocode.search_promo_token
    @referrals   = referrals_for_smart_listing
  end
end
