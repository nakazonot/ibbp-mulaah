ActiveAdmin.register Translation, as: 'CustomizeSiteContent' do
  menu label: 'Customize Site Content', priority: 60

  config.sort_order = 'key_asc'

  permit_params :value

  index title: 'Customize Site Content' do
    column :key
    column :value do |translation|
      truncate(translation.value, length: 255)
    end
    column :updated_at
    actions defaults: true
  end

  form do |f|
    f.inputs 'Parameter value' do
      f.input :key, input_html: { disabled: true }
      f.input :value
      f.input :interpolations,
              label: 'Available Variables',
              input_html: { value: ApplicationHelper.format_translation_variables(f.object.interpolations), disabled: true }
    end
    f.actions
  end

  show do
    attributes_table do
      row :key
      row :value
      row :updated_at
    end
  end

  filter :key
  filter :filter_by_value, as: :string, label: 'Value'

end
