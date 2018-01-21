class Services::Promocode::AddToUser
  attr_reader :promocode, :error, :is_buy_tokens_promocode

  ERROR_PROMOCODE_NOT_EXIST               = 'error_promocode_not_exist'.freeze
  ERROR_PROMOCODE_NOT_VALID               = 'error_promocode_not_valid'.freeze
  ERROR_PROMOCODE_NOT_ACTUAL              = 'error_promocode_not_actual'.freeze
  ERROR_PROMOCODE_NOT_ADDED               = 'error_promocode_not_added'.freeze
  ERROR_PROMOCODE_ALREADY_USED            = 'error_promocode_already_used'.freeze
  ERROR_PROMOCODE_NOT_ENOUGH_PROMO_TOKENS = 'error_promocode_not_enough_promo_tokens'.freeze

  def initialize(user, code)
    @user       = user
    @code       = code
  end

  def call
    find_promocode
    add_promocode_to_user unless @error

    self
  end

  private

  def find_promocode
    @promocode = ::Promocode.by_code(@code).first
    return @error = ERROR_PROMOCODE_NOT_EXIST if @promocode.blank?
    if @promocode.is_promo_token?
      return @error = ERROR_PROMOCODE_NOT_EXIST unless Promocode.promo_token_enabled?
      return @error = ERROR_PROMOCODE_NOT_ENOUGH_PROMO_TOKENS unless TokenTransaction.enough_promo_token_balance(@user.id)
    end
    return @error = ERROR_PROMOCODE_NOT_VALID unless @promocode.promocode_valid?
    @error = ERROR_PROMOCODE_NOT_ACTUAL unless promocode_actual?
  end

  def add_promocode_to_user
    return @error = ERROR_PROMOCODE_ALREADY_USED if @promocode.is_onetime? && promocode_used?
    find_or_initialize_user_promocode

    @error = ERROR_PROMOCODE_NOT_ADDED unless @user_promocode.update_attributes(promocode_user_attrs)
  end

  def find_or_initialize_user_promocode
    @user_promocode   = PromocodesUser.by_user(@user.id).by_promocode(@promocode.id).not_used.first
    @user_promocode ||= PromocodesUser.new
  end

  def promocode_used?
    PromocodesUser.exists?(user_id: @user.id, promocode_id: @promocode.id)
  end

  def promocode_user_attrs
    { user: @user, promocode: @promocode, promocode_property: @promocode.property, updated_at: Time.current }
  end

  def promocode_actual?
    ico_stage                 = IcoStage.find(Parameter.get_all['ico.stage_id'])
    @is_buy_tokens_promocode  = ico_stage.buy_token_promocode_id == @promocode.id

    @is_buy_tokens_promocode || @promocode.actual?
  end
end
