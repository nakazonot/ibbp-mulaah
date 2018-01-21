require_dependency 'api/v1/validators/payments_order_column'
require_dependency 'api/v1/validators/order_direction'
require_dependency 'api/v1/validators/payment_type'
require_dependency 'api/v1/validators/iso3166'
require_dependency 'api/v1/validators/gender'
require_dependency 'api/v1/validators/max_file_size'
require_dependency 'api/v1/validators/kyc_image_format'

module API::V1::Helpers::Users
  extend Grape::API::Helpers

  params :sign_up do
    requires :email,                  type: String,   desc: 'Email'
    requires :password,               type: String,   desc: 'Password'
    requires :password_confirmation,  type: String,   desc: 'Password confirmation'
    requires :registration_agreement, type: Boolean,  desc: 'Registration agreement'
    optional :name,                   type: String,   desc: 'Name'
    optional :middle_name,            type: String,   desc: 'Middle name'
    optional :last_name,              type: String,   desc: 'Last name'
    optional :phone,                  type: String,   desc: 'Phone'
    optional :referral_code,          type: String,   desc: 'Referral code'
    optional :sign_up_ip,             type: String,   desc: 'Registered user IP'
    optional :confirmation_uri,       type: String,   desc: 'Confirmation URI (base). Account confirmation url.
                                                             Will be passed to Confirmation instructions email with
                                                             confirmation code.
                                                             For example, https://example.com/users/confirmation
                                                             Parameter is optional if server configured with SKIP_USER_CONFIRMATION=1'
    optional :referral_uri,           type: String,   desc: 'Referral URI (base). Url for referral program. For example, https://example.com/'
  end

  params :sign_in do
    requires :email,                  type: String,   desc: 'Email'
    requires :password,               type: String,   desc: 'Password'
    optional :otp,                    type: String,   desc: 'One Time Password (2FA)'
    optional :unlock_uri,             type: String,   desc: 'Unlock URI (base)'
  end

  params :confirmation do
    requires :confirmation_token,     type: String,   desc: 'Confirmation token'
  end

  params :confirmation_repeat do
    requires :email,                  type: String,   desc: 'Email'
    optional :confirmation_uri,       type: String,   desc: 'Confirmation URI (base)'
    optional :referral_uri,           type: String,   desc: 'Referral URI (base)'
  end

  params :password_reset_request do
    requires :email,                  type: String,   desc: 'Email'
    optional :edit_password_uri,      type: String,   desc: 'Reset URI (base)'
  end

  params :password_edit do
    requires :reset_password_token,   type: String,   desc: 'Password reset token'
    requires :password,               type: String,   desc: 'Password'
    requires :password_confirmation,  type: String,   desc: 'Password confirmation'
  end

  params :unlock do
    requires :unlock_token,           type: String,   desc: 'Unlock token'
  end

  params :promocode_new do
    requires :code,                   type: String,   desc: 'Promotional code'
  end

  params :user_update do
    optional :name,                   type: String,   desc: 'Name'
    optional :middle_name,            type: String,   desc: 'Middle name'
    optional :last_name,              type: String,   desc: 'Last name'
    optional :phone,                  type: String,   desc: 'Phone'
    if -> { Parameter.eth_wallet_enabled? }
      optional :eth_wallet,           type: String,   desc: 'ETH Wallet'
    end
    if -> { Parameter.btc_wallet_enabled? }
      optional :btc_wallet,           type: String,   desc: 'BTC Wallet'
    end
  end

  params :user_password_update do
    requires :current_password,       type: String,   desc: 'Current password.'
    requires :password,               type: String,   desc: 'New password.'
    requires :password_confirmation,  type: String,   desc: 'New password (confirmation).'
  end

  params :user_password_create do
    requires :password,               type: String,   desc: 'New password.'
    requires :password_confirmation,  type: String,   desc: 'New password (confirmation).'
  end

  params :kyc_create do
    requires :phone,                  type: String,                        desc: 'Phone.'
    requires :first_name,             type: String,                        desc: 'First name.'
    optional :middle_name,            type: String,                        desc: 'Middle name.'
    requires :last_name,              type: String,                        desc: 'Last name.'
    optional :document_number,        type: String,                        desc: 'Identification Number.'
    requires :address_line_1,         type: String,                        desc: 'Address line 1.'
    optional :address_line_2,         type: String,                        desc: 'Address line 2.'
    optional :address_line_3,         type: String,                        desc: 'Address line 2.'
    requires :country_code,           type: String,                        desc: 'Country code (ISO 3166).', iso3166: true
    requires :city,                   type: String,                        desc: 'City.'
    requires :state,                  type: String,                        desc: 'State.'
    requires :citizenship,            type: String,                        desc: 'Citizenship (ISO 3166).',  iso3166: true
    requires :gender,                 type: String,                        desc: 'Gender.',                  gender: true
    requires :dob,                    type: Date,                          desc: 'Date of birth.'
    requires :document_front,         type: File,                          desc: 'Frontside of document.', max_file_size: true, kyc_image_format: true
    optional :document_back,          type: File,                          desc: 'Backside of document.',  max_file_size: true, kyc_image_format: true
    requires :document_selfie,        type: File,                          desc: 'Selfie.',                max_file_size: true, kyc_image_format: true
    optional :document_proof,         type: File,                          desc: 'Proof.',                 max_file_size: true, kyc_image_format: true
  end
  
  def user_update_params
    permitted_attributes = [:name, :phone, :middle_name, :last_name]
    permitted_attributes << :eth_wallet if Parameter.eth_wallet_enabled?
    permitted_attributes << :btc_wallet if Parameter.btc_wallet_enabled?

    ActionController::Parameters.new(params).permit(permitted_attributes)
  end

  def sign_up_params
    params[:referral_id] = User.find_by(referral_uuid: params[:referral_code])&.id
    attrs                = [
      :name,
      :middle_name,
      :last_name,
      :phone,
      :email,
      :password,
      :sign_up_ip,
      :referral_id,
      :password_confirmation,
      :registration_agreement,
    ]

    ActionController::Parameters.new(params).permit(attrs)
  end

  def sign_in_params
    ActionController::Parameters.new(params).permit(:email, :password, :otp)
  end

  def password_edit_params
    ActionController::Parameters.new(params).permit(:reset_password_token, :password, :password_confirmation)
  end

  def change_password_params
    ActionController::Parameters.new(params).permit(:current_password, :password, :password_confirmation)
  end

  def create_password_params
    params[:uses_default_password] = false
    ActionController::Parameters.new(params).permit(:password, :password_confirmation, :uses_default_password)
  end

  def user_email_to_downcase
    params[:email] = params[:email].downcase if params[:email].present?
  end
end
