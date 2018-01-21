class AddTranslationsForOauthNotify < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'errors.messages.user_not_exist',
      value: 'User does not exist.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'errors.messages.password_invalid',
      value: 'Invalid password, try again.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'errors.messages.password_already_created',
      value: 'The password has been already created.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'errors.messages.password_set_request',
      value: 'You must set a password before this action.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'errors.messages.otp_not_enabled',
      value: 'Two-factor authentication not enabled.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'errors.messages.otp_invalid_code',
      value: 'Invalid code, try again.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.otp_codes_regenerated',
      value: 'Backup codes have been successfully regenerated.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.otp_enabled',
      value: 'Two-factor authentication has been enabled.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.otp_disabled',
      value: 'Two-factor authentication has been disabled.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.password_created',
      value: 'Password successfully created.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.oauth_completion_registration',
      value: 'To complete the registration, you must enter the missing information.',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'notice.messages.oauth_account_linking',
      value: 'To confirm the binding of your account, you must enter the password from the BB account.',
      interpolations: %w[]
    )
  end
end
