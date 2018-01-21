class API::V1::Validators::KycImageFormat < Grape::Validations::Base
  ALLOWED_TYPES = %w[
    image/gif
    image/jpeg
    image/pjpeg
    image/png
  ]

  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    document = params[attr_name]
    return if ALLOWED_TYPES.include?(document.type)
    fail Grape::Exceptions::Validation,
         params: [@scope.full_name(attr_name)],
         message: I18n.t('errors.messages.invalid_file_format')
  end
end
