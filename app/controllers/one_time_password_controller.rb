class OneTimePasswordController < ApplicationController
  before_action :authenticate_user!

  def generate_secret
    generating = Services::OTP::GenerateSecret.new(current_user, request.host).call

    ajax_ok({
      secret: generating.secret,
      qr_code: generating.qr_code,
      label: generating.label,
      uri: generating.uri
    })
  end

  def enable_otp
    enabling = Services::OTP::Enable.new(current_user, params[:code])
    enabling.call

    if enabling.error == Services::OTP::Enable::ERROR_INVALID_CODE
      return ajax_error({ msg: I18n.t('otp.notice.invalid_code') })
    end

    ajax_ok({ msg: I18n.t('otp.notice.enabled'), codes: enabling.backup_codes })
  end

  def regenerate_backup_codes
    return ajax_error({ msg: t('errors.messages.password_set_request') }) if current_user.uses_default_password

    regenerating = Services::OTP::RegenerateBackupCodes.new(current_user, params[:password])
    regenerating.call
    if regenerating.error == Services::OTP::RegenerateBackupCodes::ERROR_PASSWORD_INVALID
      return ajax_error({ msg: I18n.t('otp.notice.invalid_password') })
    elsif regenerating.error == Services::OTP::RegenerateBackupCodes::ERROR_OTP_REQUIRED
      return ajax_error({ msg: I18n.t('otp.notice.required')})
    end

    ajax_ok({ msg: I18n.t('otp.notice.backup_code_regenerated'), codes: regenerating.codes })
  end

  def disable_otp
    return ajax_error({ msg: t('errors.messages.password_set_request') }) if current_user.uses_default_password

    disabling = Services::OTP::Disable.new(current_user, params[:password])
    disabling.call

    if disabling.error == Services::OTP::Disable::ERROR_PASSWORD_INVALID
      return ajax_error({ msg: I18n.t('otp.notice.invalid_password') })
    end

    ajax_ok({ msg: I18n.t('otp.notice.disabled') })
  end

  def create_password
    return ajax_error({ msg: t('errors.messages.password_already_created') }) unless current_user.uses_default_password

    if current_user.update_attributes(create_password_params.merge(uses_default_password: false))
      bypass_sign_in(current_user)
      return ajax_ok({ msg: t('notice.messages.password_created') })
    end

    ajax_error({ msg: current_user.errors.full_messages })
  end

  private

  def create_password_params
    params.permit(:password, :password_confirmation)
  end
end
