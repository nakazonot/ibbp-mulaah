class API::V1::Validators::PaymentsOrderColumn < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    unless API::V1::Helpers::Payments::SORTABLE_ATTRIBUTES.keys.include?(params[attr_name].to_sym)
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.invalid')
    end
  end
end
