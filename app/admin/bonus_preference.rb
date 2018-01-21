ActiveAdmin.register BonusPreference do
  config.batch_actions = false
  config.sort_order    = 'min_investment_amount_asc'

  menu false
  belongs_to :ico_stage

  permit_params :min_investment_amount, :bonus_percent

  index do
    column :min_investment_amount
    column :bonus_percent

    actions
  end

  form do |f|
    f.inputs 'Bonus' do
      f.input :min_investment_amount, as: :string
      f.input :bonus_percent, as: :string
    end
    f.actions
  end


  show do
    attributes_table do
      row :min_investment_amount
      row :bonus_percent
    end
  end

end
