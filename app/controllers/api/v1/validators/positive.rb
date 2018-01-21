class API::V1::Validators::Positive < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    if params[attr_name].to_f < 0
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.greater_than', count: 0)
    end
  end
end
