class API::V1::Validators::PaymentType < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    unless Payment.payment_types.to_h.values.include?(params[attr_name])
      fail Grape::Exceptions::Validation,
           params: [@scope.full_name(attr_name)],
           message: I18n.t('errors.messages.not_exist')
    end
  end
end
