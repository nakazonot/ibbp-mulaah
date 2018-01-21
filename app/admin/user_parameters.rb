ActiveAdmin.register UserParameter do
  config.batch_actions = false
  config.sort_order    = 'id_asc'

  menu false
  belongs_to :user

  permit_params :parameter_id, :value

  index do
    column :id
    column :parameter do |up|
      up.parameter.name
    end
    column :value

    actions
  end

  form do |f|
    f.inputs 'Parameter' do
      f.input :parameter_id,
              as: :select,
              collection: parameters_collection(f.object),
              label: 'Parameter',
              include_blank: false
      f.input :value
    end
    f.actions
  end


  show do
    attributes_table do
      row :id
      row :parameter do |up|
        up.parameter.name
      end
      row :value
    end
  end

  controller do
    def parameters_collection(obj)
      user_id = obj.user.id

      if obj.new_record?
        parameters_ids = Parameter.can_overloaded.ids - UserParameter.by_user(user_id).pluck(:parameter_id)
        parameters     = Parameter.where(id: parameters_ids)
      else
        parameters = [obj.parameter]
      end

      parameters.pluck(:name, :id)
    end

    helper_method :parameters_collection
  end
end
