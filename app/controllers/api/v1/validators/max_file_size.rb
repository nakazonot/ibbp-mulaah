class API::V1::Validators::MaxFileSize < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].blank?

    document      = params[attr_name]
    max_file_size = Parameter.kyc_max_file_size
    if (document.tempfile.size / 1024.0 / 1024.0) >= max_file_size
      fail Grape::Exceptions::Validation,
             params: [@scope.full_name(attr_name)],
             message: I18n.t('errors.messages.max_file_size', max_file_size: max_file_size)
    end
  end
end
