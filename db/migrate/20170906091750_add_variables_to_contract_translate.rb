class AddVariablesToContractTranslate < ActiveRecord::Migration[5.1]
  def change
    translation = Translation.find_by(key: 'main.contract_template_html')
    translation.interpolations += %w[name email]
    translation.save
  end
end
