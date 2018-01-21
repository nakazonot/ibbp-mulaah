class UserParameter < ApplicationRecord
  belongs_to :user
  belongs_to :parameter

  scope :by_user,           ->(user_id)  { where(user_id: user_id) }
  scope :by_parameter,      ->(param_id) { where(parameter_id: param_id) }

  validates :parameter_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :parameter_id, scope: :user_id
  validates :value, presence: true, referral_bonus_percent: true, parameter_overload: true

  def self.get_all_by_user(user)
    result = UserParameter.by_user(user.id).joins(:parameter).pluck(:name, :value).to_h
    result['user.referral_user_bonus_percent']   = result['user.referral_user_bonus_percent'].to_f if result['user.referral_user_bonus_percent'].present?
    result['user.referral_bonus_percent']        = result['user.referral_bonus_percent'].split(',').map(&:to_f) if result['user.referral_bonus_percent'].present?
    result
  end

  def self.get_user_parameter(user, parameter)
    user_parameter = get_all_by_user(user)[parameter]
    return user_parameter if user_parameter.present?
    parameters = Parameter.get_all
    parameters[parameter]
  end
end
