class ChangeInterpolationContract < ActiveRecord::Migration[5.1]
  def change
    translation = Translation.find_by(key: 'main.contract_template_html')
    translation.interpolations += %w[contract_created_at]
    translation.save
  end
end
