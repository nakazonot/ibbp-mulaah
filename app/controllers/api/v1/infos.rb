class API::V1::Infos < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Infos

  resource :infos do
    params { use :infos_system }
    desc 'Main information about system.'
    get :system do
      system_info_service = Services::SystemInfo::SystemInfo.new(params)
      system_info         = system_info_service.call

      if system_info_service.error == Services::SystemInfo::SystemInfo::ERROR_NOT_AUTHORIZED
        fail API::V1::Errors::NotAuthorizedError
      elsif system_info_service.error == Services::SystemInfo::SystemInfo::ERROR_ICO_CLOSED
        fail API::V1::Errors::ICOClosedError, { ico_stages: system_info_service.ico_stages }
      end

      system_info
    end

    desc 'Information about raised.'
    params { use :infos_raised }
    get :raised do
      raised_info_service = Services::SystemInfo::Raised.new(params)
      raised_info         = raised_info_service.call

      if raised_info_service.error == Services::SystemInfo::Raised::ERROR_NOT_AUTHORIZED
        fail API::V1::Errors::NotAuthorizedError
      end

      raised_info
    end

    desc 'Abilities map.'
    get :abilities do
      Services::SystemInfo::AbilitiesMap.new(current_user&.id).call
    end
  end
end
