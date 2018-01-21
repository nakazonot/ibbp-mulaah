class Services::PaymentAddress::PromoTokensAddressGetter
  include Concerns::Log::Logger

  def initialize(user:)
    @user              = user
    @currency          = 'ETH'
    @payment_system    = PaymentSystemType::ANY_PAY_COINS
    @address_type      = PaymentAddressType::PROMO_TOKENS
    @config_parameters = Parameter.get_all
  end

  def call
    address = ::PaymentAddress.by_user(@user.id).by_payment_system(@payment_system).by_address_type(@address_type).find_by(currency: @currency)
    return address if address.present?

    log_info("User ##{@user.id} requested #{@currency}/#{@payment_system} promo token address.")

    address = ::PaymentAddress.not_user.by_payment_system(@payment_system).by_address_type(@address_type).order(:id).find_by(currency: @currency)
    if address.blank?
      log_warn("No free #{@currency}/#{@payment_system} promo token addresses for user ##{@user.id}, need to generate more!")
      return nil
    end

    address.user_id             = @user.id
    unless address.save(validate: false)
      log_error("Can not assign #{@currency}/#{@payment_system} promo token address ##{address.id} to user ##{@user.id}.")
      return nil
    end

    FreePromoTokenAddressGenerateJob.perform_later
    log_info("#{@currency}/#{@payment_system} promo token address ##{address.id} was assigned to user ##{@user.id}.")

    address
  rescue ActiveRecord::StaleObjectError => e
    log_error("#{e.message} Promo token address #{address.id} is already assigned, but user #{@user.id} tried to reserve it.")
    nil
  end
end