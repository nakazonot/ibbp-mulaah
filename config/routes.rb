Rails.application.routes.draw do
  root 'icobox#index'

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.role == User::ROLE_ADMIN } do
    mount Sidekiq::Web => '/sidekiq_monitor'
  end

  mount API::Root,                  at: '/api'
  mount GrapeSwaggerRails::Engine,  at: '/api/doc'
  mount LetterOpenerWeb::Engine,    at: '/letter_opener' if Rails.env.development?

  resources :payment_notifications, only: [:create]
  resources :invoiced_notifications, only: [:create]
  resources :anypaycoins_notifications, only: [:create]
  resources :icos_id_kyc_notifications, only: [:create]

  devise_for :users, controllers: {
    registrations:      'users/registrations',
    sessions:           'users/sessions',
    confirmations:      'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  ActiveAdmin.routes(self)

  get   '/profile',                                    to: 'profile#edit'
  get   '/profile/edit',                               to: 'profile#edit'
  patch '/profile',                                    to: 'profile#update'
  post  '/profile/get-promo-token-address',            to: 'profile#ajax_get_promo_token_address'
  get   '/profile/payments',                           to: 'profile#payments'
  patch '/profile/change-password',                    to: 'profile#change_password'
  get   '/close-ico',                                  to: 'icobox#close_ico'
  patch '/coinbox/generate-invoice',                   to: 'icobox#ajax_generate_invoice'
  post  '/coinbox/coin-price',                         to: 'icobox#ajax_coin_price'
  post  '/coinbox/coin-for-total',                     to: 'icobox#ajax_coin_for_total'
  post  '/coinbox/coins-for-total-balances',           to: 'icobox#ajax_coins_for_all_balances'
  post  '/coinbox/get-address',                        to: 'icobox#ajax_get_address'
  post  '/coinbox/contract-accept',                    to: 'icobox#ajax_contract_accept'
  post  '/coinbox/buy-coins',                          to: 'icobox#ajax_buy_coins'
  post  '/user/agreement',                             to: 'profile#agreement'
  post  '/user/add-promocode',                         to: 'profile#ajax_add_promocode'
  get   '/user/get-promocode',                         to: 'profile#ajax_get_promocode'
  get   '/agreement/terms-of-services',                to: 'agreement#terms_of_services'
  get   '/distribution',                               to: 'static#distribution'
  get   '/contract/:contract_uuid/token-purchase',     to: 'agreement#token_purchase',          as: 'contract_agreement'
  get   '/one-time-password/generate-secret',          to: 'one_time_password#generate_secret'
  post  '/one-time-password/create-password',          to: 'one_time_password#create_password'
  post  '/one-time-password/enable',                   to: 'one_time_password#enable_otp'
  post  '/one-time-password/disable',                  to: 'one_time_password#disable_otp'
  post  '/one-time-password/regenerate-backup-codes',  to: 'one_time_password#regenerate_backup_codes'
  get   '/ico-main-info',                              to: 'api#ico_main_info'
  get   '/ico-raised',                                 to: 'api#ico_raised'
  post  '/oauth/confirm-account-linking',              to: 'omniauth#confirm_account_linking'
  post  '/oauth/completion-registration',              to: 'omniauth#completion_oauth_registration'
  get   '/oauth/confirmation-email',                   to: 'omniauth#confirmation_email'

  match '/404',                                        to: 'static#error_404',                  via: :all
  match '/500',                                        to: 'static#error_500',                  via: :all
  match '*unmatched_route',                            to: 'static#error_404',                  via: :all
end
