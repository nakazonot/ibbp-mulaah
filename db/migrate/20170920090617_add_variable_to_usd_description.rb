class AddVariableToUsdDescription < ActiveRecord::Migration[5.1]
  def change
    translation = Translation.find_by(key: 'main.step.make_deposit.usd_description_html')
    translation.interpolations += %w[min_amount_for_transfer]
    translation.save
  end
end
