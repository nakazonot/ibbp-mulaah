ActiveAdmin.register Promocode do
  menu priority: 45

  permit_params :code, :discount_type, :discount_amount, :num_total, :is_aggregated_discount, :comment, :expires_at, :is_onetime, :owner_id, :owner_bonus, :is_promo_token

  index do
    selectable_column
    id_column
    column :code
    column :discount_type do |promocode|
      Promocode.discount_types[promocode.discount_type]
    end
    column :discount_amount
    column 'Usages' do |promocode|
      ApplicationHelper.format_counter(promocode.num_used, promocode.num_total)
    end
    column :is_promo_token
    column :expires_at
    column :created_at
    actions
  end

  filter :code
  filter :created_at
  filter :is_valid
  filter :is_promo_token if Promocode.promo_token_enabled?

  form do |f|
    f.inputs 'Promocode' do
      f.input :code, label: 'Promocode'
      f.input :discount_type, as: :select, collection: Promocode.discount_types.collect { |disc| [ disc.second, disc.first ] }
      f.input :discount_amount, as: :string
      f.input :num_total, as: :string
      f.input :is_aggregated_discount
      f.input :is_onetime
      div class: 'input-group date' do
        f.input :expires_at, as: :string
      end
      f.input :owner_id, as: :select, collection: User.all.collect { |user| [ user.email, user.id ] }
      f.input :owner_bonus, as: :string
      f.input :is_promo_token, label: 'Promo token' if Promocode.promo_token_enabled?
      f.input :comment, as: :text
    end
    f.actions
  end

  show do |p|
    attributes_table do
      row :id
      row :code
      row :discount_type do |promocode|
        Promocode.discount_types[promocode.discount_type]
      end
      row :discount_amount
      row :is_aggregated_discount
      row :is_onetime
      row 'Usages' do
        ApplicationHelper.format_counter(p.num_used, p.num_total)
      end
      row :is_valid
      row :comment
      row :expires_at
      row :owner_id do |promocode|
        promocode.owner.email if promocode.owner.present?
      end
      row :owner_bonus
      row :is_promo_token
      row :created_at
      row :updated_at
    end
  end
end
