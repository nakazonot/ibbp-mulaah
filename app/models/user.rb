class User < ApplicationRecord

  include Concerns::Log::Logger
  include TrackingLabels

  acts_as_paranoid

  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ConditionalValidations

  attr_accessor :skip_password_validation, :skip_welcome_email
  attribute :otp_secret

  alias_attribute :first_name, :name

  PASSWORD_REGEXP       = '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).'
  ROLE_ADMIN            = 'admin'
  ROLE_ADMIN_READ_ONLY  = 'admin_read_only'
  ROLE_USER             = 'user'
  ROLE_SUPPORT          = 'support'

  has_many   :payment_addresses
  has_many   :buy_tokens_contract
  belongs_to :referral, class_name: 'User', optional: true
  has_many   :payments
  has_many   :promocodes_users
  has_many   :promocodes, through: :promocodes_users
  has_many   :oauth_providers, class_name: UsersOauthProvider.name
  has_many   :user_parameters
  has_one    :kyc_verification

  devise :confirmable, :lockable, :omniauthable, :encryptable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable,
         :two_factor_authenticatable, :two_factor_backupable, :jwt_authenticatable, jwt_revocation_strategy: self,
         otp_secret_encryption_key: ENV['TWO_FACTOR_ENCRYPTION_KEY'],
         otp_number_of_backup_codes: 10
  devise omniauth_providers: Devise.omniauth_configs.keys

  scope :customer,      ->          { where(role: ROLE_USER) }
  scope :referrals,     ->(user_id) { where(referral_id: user_id) }
  scope :token_holders, ->          { customers.having("SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}) > 0") }

  validates :phone, phone: { allow_blank: true, message: 'must contain 5 to 19 digits' }, if: :validate_if_phone_require?
  validates :eth_wallet, eth_wallet: { allow_blank: true }, if: :validate_if_eth_wallet_require?
  validates :btc_wallet, btc_wallet: { allow_blank: true }, if: :validate_if_btc_wallet_require?

  validate :password_complexity
  validates_acceptance_of :registration_agreement, accept: true, on: :create
  validates :name, presence: true, if: Proc.new { |user| user.ability.can?(:require_user_name_input_on_sign_up, :user)}, on: :create
  validates :name, presence: true, if: Proc.new { |user| user.ability.can?(:require_user_name_input_on_sign_up, :user) && user.validate_if_name_require?}, on: :update
  validates :kyc_date, presence: true, if: Proc.new { |user| user.kyc_result }

  before_create :set_default_values
  after_commit :send_welcome_email

  def cpa_postback_sign_up
    SendCpaPostbackJob.perform_later(CpaPostback::ACTION_SIGN_UP, self.id)
  end

  def display_name
    "#{ email }"
  end

  def self.find_by_email(email)
    self.where('lower(email) = ?', email&.downcase).first
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def set_default_values
    set_sign_up_data

    self.skip_confirmation! unless Parameter.user_confirmation_required?
    self.role               = ROLE_USER if self.role.blank?
    self.referral_uuid      = SecureRandom.hex(12)

    false
  end

  def set_sign_up_data
    geoip ||= GeoIP.new("#{Rails.root}/db/GeoIP.dat")
    geoip_location = geoip.country(self.sign_up_ip)
    if geoip_location.present?
      self.sign_up_country = geoip_location['country_code2']
    end
  end

  def self.customers
    select("users.*,
            COUNT(payments.id) AS transactions_total,
            SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}) AS coins_total")
    .joins('LEFT JOIN payments ON users.id = payments.user_id AND payments.deleted_at IS NULL')
    .group('users.id')
  end

  def self.referrals_with_bounty(user_id)
    # First query returns level 1 referrals (referrals that followed by current user link). Referrals without payments will be selected too.
    # Second query returns referrals from other levels (referrals of referrals). Only referrals with payments will be selected.
    User.find_by_sql(['
        SELECT id, email, created_at, confirmed_at, SUM(iso_coin_amount) AS bounty_amount, COALESCE(referral_level, 1) AS referral_level
        FROM
        (
          SELECT users.id, users.email, users.created_at, users.confirmed_at, payments.id AS payment_id, payments.referral_level, payments.iso_coin_amount
          FROM users
          LEFT JOIN payments ON payments.user_id = :user_id AND users.id = payments.referral_user_id AND payments.deleted_at IS NULL AND payments.payment_type = :payment_type
          WHERE users.referral_id = :user_id

          UNION

          SELECT users.id, users.email, users.created_at, users.confirmed_at, payments.id AS payment_id, payments.referral_level, payments.iso_coin_amount
          FROM users
          JOIN payments ON payments.user_id = :user_id AND users.id = payments.referral_user_id AND payments.deleted_at IS NULL AND payments.payment_type = :payment_type
          WHERE users.referral_id <> :user_id
        ) AS referral_users
        GROUP BY id, referral_level, email, created_at, confirmed_at
        ORDER BY referral_level ASC, email
      ', { user_id: user_id, payment_type: Payment::PAYMENT_TYPE_REFERRAL_BOUNTY } ])
  end

  def self.referrals_with_bounty_for_balance(user_id)
    users = User.find_by_sql(['
        SELECT id, email, created_at, confirmed_at, currency_buyer as currency, SUM(amount_buyer) as bounty_amount, COALESCE(referral_level, 1) as referral_level
        FROM
        (
          SELECT users.id, users.email, users.created_at, users.confirmed_at, payments.id AS payment_id, payments.referral_level, payments.amount_buyer, payments.currency_buyer
          FROM "users"
          LEFT JOIN payments ON payments.user_id = :user_id AND users.id = payments.referral_user_id AND payments.deleted_at IS NULL AND payments.payment_type = :payment_type
          WHERE users.referral_id = :user_id

          UNION

          SELECT users.id, users.email, users.created_at, users.confirmed_at, payments.id AS payment_id, payments.referral_level, payments.amount_buyer, payments.currency_buyer
          FROM "users"
          JOIN payments ON payments.user_id = :user_id AND users.id = payments.referral_user_id AND payments.deleted_at IS NULL AND payments.payment_type = :payment_type
          WHERE users.referral_id <> :user_id
        ) as referral_users
        GROUP BY id, referral_level, email, created_at, confirmed_at, currency
        ORDER BY referral_level ASC, email ASC, currency
      ', { user_id: user_id, payment_type: Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE } ])
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def send_reset_password_instructions_register_from_admin
    token = set_reset_password_token
    send_devise_notification(:reset_password_instructions_register_from_admin, token)
    token
  end

  def create_otp_secret!(need_recreate = false)
    update_attributes(otp_secret: User.generate_otp_secret) if need_recreate || self.otp_secret.blank?
  end

  def two_factor_enabled?
    otp_required_for_login?
  end

  def create_otp_backup_codes!
    codes = generate_otp_backup_codes!
    save!

    codes
  end

  def enable_two_factor!
    update_attributes(otp_required_for_login: true)
    create_otp_backup_codes!
  end

  def disable_two_factor!
    update_attributes(
      otp_required_for_login:      false,
      encrypted_otp_secret:        nil,
      encrypted_otp_secret_iv:     nil,
      encrypted_otp_secret_salt:   nil,
      otp_backup_codes:            nil
    )
  end

  def increment_failed_attempts!(unlock_uri: nil)
    self.failed_attempts ||= 0
    self.failed_attempts += 1
    if attempts_exceeded? && !access_locked?
      lock_access!({ send_instructions: unlock_uri.nil? })
      send_unlock_instructions_from_api(unlock_uri) if unlock_uri.present?
    else
      save(validate: false)
    end
  end

  def get_active_promocode
    user_promocode = PromocodesUser.search_actual_promocode_by_user(id)
    user_promocode.present? ? user_promocode.promocode : nil
  end

  def is_referral?
    self.referral_id.present?
  end

  def self.with_payments(payments_type)
    where('payments.payment_type IN (?)', payments_type)
      .joins("LEFT JOIN payments ON users.id = payments.user_id AND payments.deleted_at IS NULL")
      .where('payments.status = ?', Payment::PAYMENT_STATUS_COMPLETED)
      .group('users.id')
      .having('SUM(amount_buyer) > 0')
  end

  def self.deposited_only
    balances = with_payments([Payment::PAYMENT_TYPE_BALANCE]).pluck('users.id, SUM(payments.amount_buyer)').to_h
    refunds  = with_payments([Payment::PAYMENT_TYPE_REFUND]).pluck('users.id, SUM(payments.amount_buyer)').to_h
    purchase = with_payments([Payment::PAYMENT_TYPE_PURCHASE]).pluck('users.id, SUM(payments.amount_buyer)').to_h

    refunds.each { |user_id, amount| balances[user_id] -= amount if balances[user_id].present? }

    balances.except(*purchase.keys).select { |user_id, amount| amount > 0 }
  end

  def consume_otp_attempt!(code)
    validate_and_consume_otp!(code) || invalidate_otp_backup_code!(code)
  end

  def set_unlock_token
    token, encoded_token = Devise.token_generator.generate(self.class, :unlock_token)
    self.unlock_token = encoded_token
    save(validate: false)

    token
  end

  def set_reset_password_token!
    set_reset_password_token
  end

  def send_confirmation_notification_from_api(confirmation_uri, referral_uri = nil)
    return unless Parameter.user_confirmation_required?

    send_devise_notification(
      :confirmation_notification_from_api,
      confirmation_token,
      confirmation_uri: confirmation_uri,
      referral_uri: referral_uri
    )
  end

  def send_reset_password_instructions_from_api(edit_password_uri)
    token = set_reset_password_token!
    send_devise_notification(:reset_password_instructions_from_api, token, edit_password_uri: edit_password_uri)
  end

  def send_unlock_instructions_from_api(unlock_uri)
    token = set_unlock_token
    send_devise_notification(:unlock_instructions_from_api, token, unlock_uri: unlock_uri)
  end

  def available_payment_addresses
    result = []
    available_currencies = Parameter.available_currencies
    self.payment_addresses.each do |address|
      if available_currencies.has_key?(address.currency) &&
          address.payment_system == available_currencies[address.currency]['payment_system'] &&
          address.address_type == PaymentAddressType::DEPOSIT
          result << address
      end
    end
    result
  end

  def self.create_from_omniauth(provider, uid, user_attributes, need_send_confirmation: false)
    user = User.create(
      email:                  user_attributes[:email]&.downcase,
      password:               User.generate_random_password,
      name:                   user_attributes[:name],
      sign_up_ip:             user_attributes[:sign_up_ip],
      registration_agreement: true,
      uses_default_password:  true,
      is_oauth_sign_up:       true,
      confirmed_at:           Time.current
    )

    if user.persisted?
      user.oauth_providers.create(provider: provider, uid: uid)
      Services::PaymentAddress::PromoTokensAddressGetter.new(user: user).call if Promocode.promo_token_enabled?
      if need_send_confirmation
        user.send_oauth_email_confirmation
      else
        user.update_column(:oauth_email_confirmed_at, Time.current)
      end
    end

    user
  end

  def self.generate_random_password
    Faker::Base.regexify(/^([a-z]{3,6})([A-Z]{3,6})([0-9]{3,6})/).split(//).shuffle.join
  end

  def send_oauth_email_confirmation
    generate_confirmation_oauth_email_token!

    send_devise_notification(:confirmation_oauth_email_notification, oauth_email_confirmation_token)
  end

  def generate_confirmation_oauth_email_token!
    self.oauth_email_confirmation_token = Devise.friendly_token
    save(validate: false)
  end

  def self.confirm_oauth_email_by_token(confirmation_token)
    user = find_or_initialize_by(oauth_email_confirmation_token: confirmation_token)

    if user.persisted?
      if user.oauth_email_confirmed_at.present?
        user.errors.add(:email, :already_confirmed)
      else
        user.update_column(:oauth_email_confirmed_at, Time.now.utc)
      end
    else
      user.errors.add(:oauth_email_confirmation_token, :invalid)
    end

    user
  end

  def resend_oauth_email_confirmation
    errors.add(:email, :already_confirmed) if oauth_email_confirmed_at.present?

    send_oauth_email_confirmation if errors.empty?
  end

  def valid_password?(password)
    return super(password) if self.password_salt.present?

    begin
       if Devise::Encryptor.compare(self.class, encrypted_password, password)
        self.password = password
        save(validate: false)
        return true
       end
    rescue BCrypt::Errors::InvalidHash => e
      log_error("##{self.id}: #{e.message}")
    end

    false
  end

  def update_tracking_labels(labels)
    unless self.tracking_labels.nil?
      labels = self.tracking_labels.merge(labels)
      labels = Hash[labels.sort_by { |key, _value| key }]
    end

    update_column(:tracking_labels, labels) if self.tracking_labels != labels
  end

  def can_be_deleted?
    return false if coin_present?(Payment.by_user(self.id).user_total_amount_tokens)
    Payment.balances_by_user(self).each do |currency, amount|
      return false if currency_present?(amount, currency)
    end
    true
  end

  def self.find_by_filter(filter)
    return self.find_by_email(filter.downcase) if filter.include?('@')

    user   = PaymentAddress.where('lower(payment_address) = ?', filter.downcase).with_deleted.first&.user
    user ||= Payment.where('transaction_id IS NOT NULL').where('lower(transaction_id) = ?', filter.downcase).first&.user
    user ||= User.find_by('referral_uuid = ?', filter.downcase)
    user
  end

  private

  def password_complexity
    if password.present? and not password.match(Regexp.new(PASSWORD_REGEXP))
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
  end

  def password_required?
    return false if skip_password_validation
    super
  end

  def send_welcome_email
    return unless self.skip_welcome_email.to_b == false &&
                  self.previous_changes.key?(:confirmed_at) &&
                  self.previous_changes[:confirmed_at].second.present?

    if I18n.t('message.welcome_email_subject', default: '').present? &&
       I18n.t('message.welcome_email_html', default: '').present?
      UserMailer.welcome_email(self.id).deliver_later
    end
  end

end
