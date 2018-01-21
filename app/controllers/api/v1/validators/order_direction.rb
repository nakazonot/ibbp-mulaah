class API::V1::Validators::OrderDirection < Grape::Validations::Base
  DIRECTIONS = %i[asc desc]

  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    unless DIRECTIONS.include?(params[attr_name].to_sym)
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.invalid')
    end
  end
end
