class API::V1::Validators::ISO8601 < Grape::Validations::Base
  include TimeConcern

  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    unless datetime_in_iso8601?(params[attr_name].to_s)
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.invalid')
    end
  end
end
