class RemoveBonusPercent < ActiveRecord::Migration[5.1]
  def change
    IcoStage.all.each do |ico_stage|
      if ico_stage.bonus_percent.present?
        ico_stage.bonus_preferences.create(min_investment_amount: 0, bonus_percent: ico_stage.bonus_percent)
      end
    end

    rename_column :ico_stages, :bonus_percent, :OBSOLETE_bonus_percent
  end
end
