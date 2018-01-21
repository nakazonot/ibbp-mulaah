ActiveAdmin.register KycPermission do
  menu label: 'KYC Permissions', priority: 100
  permit_params :permission_type, :country_list, :country_select_type, :age

  index title: 'KYC Permissions' do
    column :id
    column :permission_type
    column :country_select_type
    column :country_list
    column :age
    actions
  end

  form do |f|
    f.inputs 'KYC Permission' do
      f.input :permission_type,
        as: :select,
        collection: types_collection(f.object),
        include_blank: false
      f.input :country_select_type, as: :radio, collection: [KycPermission::COUNTRY_SELECT_TYPE_INCLUDE, KycPermission::COUNTRY_SELECT_TYPE_EXCLUDE]
      f.input :country_list,
        as: :select,
        collection: ISO3166::Country.translations.collect { |country| [ country.second, country.first ] },
        input_html: { multiple: true }
      f.input :age, as: :string
    end
    f.actions
  end

  show do |permission|
    attributes_table do
      row :id
      row :permission_type
      row :country_select_type
      row :country_list
      row :age
      row :created_at
      row :updated_at
    end
  end

  controller do
    def types_collection(obj)
      if obj.new_record?
        parameters =  KycPermission.enabled_types_for_create.collect { |permission_type| [ permission_type.second, permission_type.first ] }
      else
        parameters = [[KycPermission.get_permission_type(obj.permission_type), obj.permission_type]]
      end
      parameters
    end

    def create
      build_resource
      resource.country_list = params['kyc_permission']['country_list'].reject { |country| country.blank? }
      super
    end

    def update
      resource.country_list = params['kyc_permission']['country_list'].reject { |country| country.blank? }
      super
    end

    helper_method :types_collection
  end
end
