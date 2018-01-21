class KycPermission < ApplicationRecord
  acts_as_paranoid

  PERMISSION_TYPE_MAKE_DEPOSIT  = 'make_deposit'
  PERMISSION_TYPE_TOKEN_BUY     = 'token_buy'
  PERMISSION_TYPE_TOKEN_RECEIVE = 'token_receive'

  COUNTRY_SELECT_TYPE_INCLUDE   = 'include'
  COUNTRY_SELECT_TYPE_EXCLUDE   = 'exclude'

  validates :permission_type, presence: true, inclusion: { in: [ PERMISSION_TYPE_MAKE_DEPOSIT, PERMISSION_TYPE_TOKEN_BUY, PERMISSION_TYPE_TOKEN_RECEIVE ] }, uniqueness: true
  validates :country_select_type, allow_blank: true, inclusion: { in: [ COUNTRY_SELECT_TYPE_INCLUDE, COUNTRY_SELECT_TYPE_EXCLUDE ] }
  validates :country_select_type, presence: true, if: ->{ country_list.present? }
  validates :age, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }

  scope :by_type, ->(type) { where(permission_type: type) }

  def self.permission_types
    {
      PERMISSION_TYPE_MAKE_DEPOSIT  => 'Make Deposit',
      PERMISSION_TYPE_TOKEN_BUY     => 'Token Buy',
      PERMISSION_TYPE_TOKEN_RECEIVE => 'Token Receive'
    }
  end

  def self.get_permission_type(type)
    permission_types[type]
  end

  def self.allowed_action?(user, type)
    return true unless Parameter.kyc_verification_enabled?
    permission = self.by_type(type).first
    return true if permission.blank?
    return false if (user.kyc_verification.blank? || user.kyc_verification.status != KycStatusType::APPROVED)
    if permission.age.present?
      return false if user.kyc_verification.get_user_age < permission.age
    end
    if permission.countries.present?
      return false unless permission.countries.include?(user.kyc_verification.country_code)
    end
    true
  end

  def countries
    return nil if self.country_list.blank?
    return self.country_list if self.country_select_type == KycPermission::COUNTRY_SELECT_TYPE_INCLUDE
    ISO3166::Country.translations.keys - self.country_list
  end

  def self.enabled_types_for_create
    exists = KycPermission.distinct(:permission_type).pluck(:permission_type)
    KycPermission.permission_types.reject { |k,v| exists.include?(k) }
  end
end