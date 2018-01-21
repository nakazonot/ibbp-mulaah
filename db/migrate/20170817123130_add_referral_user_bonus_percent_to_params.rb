class AddReferralUserBonusPercentToParams < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'user.referral_user_bonus_percent', value: 0, description: 'Процент бонуса рефералу')
  end
end
