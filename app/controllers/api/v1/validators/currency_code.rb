class API::V1::Validators::CurrencyCode < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    unless Parameter.available_currencies.keys.include?(params[attr_name])
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.invalid')
    end
  end
end
