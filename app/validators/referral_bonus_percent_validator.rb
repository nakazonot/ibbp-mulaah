class ReferralBonusPercentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
  	system_parameter = Parameter.find_by(id: record.parameter_id)
  	return if system_parameter.blank? || system_parameter.name != 'user.referral_bonus_percent'
    unless format_valid?(value)
      record.errors[attribute] << (options[:message] || "parameter must be contain #{@system_referral_parameter.count} levels")
    end
  end

  protected

  def format_valid?(value)
  	@system_referral_parameter = Parameter.get_all['user.referral_bonus_percent']
  	user_referral_parameter = value.split(',').map(&:to_f)
  	user_referral_parameter.count == @system_referral_parameter.count
  end
end