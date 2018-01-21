ActiveAdmin.register Parameter do
  menu priority: 30

  config.sort_order = 'name_asc'

  member_action :sync_currencies, method: :get

  permit_params :value

  index do
    column :id
    column :name
    column :value
    column :description
    column :updated_at
    actions defaults: true do |parameter|
      item('Resync now', sync_currencies_admin_parameter_path(id: parameter.id), class: 'member_link', :data => { :confirm => 'Are you sure?' }) if can?(:sync_currencies, parameter)
    end
  end

  form do |f|
    f.inputs 'Parameter value' do
      f.input :name, input_html: { disabled: true }
      f.input :value
      f.input :description, as: :text, input_html: { readonly: true }
    end

    f.actions
  end

  filter :name
  filter :value
  filter :description

  controller do
    def sync_currencies
      Parameter.sync_available_currencies(generate_payment_addresses: true)
      return redirect_to admin_parameters_path
    rescue ApiWrappers::CoinPaymentsError
      return redirect_to admin_parameters_path, alert: 'Payment service currently unavailable. Please try again later.'
    end
  end
end
