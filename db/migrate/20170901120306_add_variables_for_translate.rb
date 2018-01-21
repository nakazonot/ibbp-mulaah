class AddVariablesForTranslate < ActiveRecord::Migration[5.1]
  def change
    interpolations = {
      'main.contract_template_html'       => %w[time_now coin_amount coin_rate currency coin_price],
      'main.step.login.description_html'  => %w[mail],
      'main.step.referral_link_html'      => %w[percent],
      'registration.agreement_label_html' => %w[link],
      'message.payment_notification_html' => %w[amount currency platform_link transaction_id email transaction_date payment_system],
    }

    Translation.where(key: interpolations.keys).each do |translate|
      translate.update_attributes(interpolations: interpolations[translate.key])
    end
  end
end