class AddParameterReferralEnable < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'referral.enabled', value: 1, description: 'Enable referral system (1 - yes, 0 - no)')
  end
end
