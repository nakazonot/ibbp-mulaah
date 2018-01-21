class DeleteOldParams < ActiveRecord::Migration[5.1]
  def change
    Parameter.where(
      name: %w[presale.bonus_percent presale.date_end presale.date_start ico.bonus_percent ico.date_end ico.date_start
               ico.support_email coin.min_payment_amount coin.rate system.current_ico_stage]
    ).destroy_all

    Parameter.where(name: 'system.authorization_key').first.update_columns(description: 'Key for getting the ICO stages data.')
  end
end
