ActiveAdmin.register LoyaltyProgram do
  menu priority: 42

  permit_params :contract, :name, :bonus_percent, :min_amount, :lifetime_hour, :is_enabled

  index do
    selectable_column
    id_column
    column :contract
    column :name
    column :bonus_percent
    column :min_amount
    column :lifetime_hour
    column :is_enabled
    column :created_at
    actions
  end

  filter :contract
  filter :name
  filter :is_enabled

  form do |f|
    f.inputs 'Loyalty Program' do
      f.input :contract
      f.input :name
      f.input :bonus_percent, as: :string
      f.input :min_amount, as: :string
      f.input :lifetime_hour, as: :string
      f.input :is_enabled
    end
    f.actions
  end

  show do |p|
    attributes_table do
      row :id
      row :contract
      row :name
      row :bonus_percent
      row :min_amount
      row :lifetime_hour
      row :is_enabled
      row :created_at
      row :updated_at
    end
  end
end
