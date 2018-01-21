class API::V1::Users < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Users
  helpers API::V1::Helpers::Payments

  resource :users do
    resource :current do
      desc 'Information about current user.'
      get do
        present(current_user, with: API::V1::Entities::User)
      end

      desc 'Update current user profile.'
      params { use :user_update }
      put do
        current_user.validated_scopes = [:phone_require, :name_require, :btc_wallet_require, :eth_wallet_require]
        current_user.update!(user_update_params)

        present(current_user, with: API::V1::Entities::User)
      end

      desc 'Get tokens amount for current user.'
      get :tokens do
        tokens = Payment.user_totals(current_user.id)

        present(tokens, with: API::V1::Entities::UserTokens)
      end

      desc 'Get referrals users and information about them.'
      paginate per_page: 10
      get :referral_users do
        fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:referral_system_enabled, :ico)

        if current_user.ability.can?(:referral_system, :tokens)
          present(paginate(User.referrals_with_bounty(current_user.id)), with: API::V1::Entities::ReferralToken)
        elsif current_user.ability.can?(:referral_system, :balance)
          paginate(ReferralsBountyBalanceFormatter.new(User.referrals_with_bounty_for_balance(current_user.id)).view_data)
        end
      end

      desc 'Get all deposits for current user.'
      get :deposits do
        Payment.balances_by_user(current_user)
      end

      desc 'Get all payments for current user.'
      paginate per_page: 10
      params { use :payments_filter }
      get :payments do
        payments = Payment.by_user(current_user.id).not_system
        payments = Payment.scope_by_type(params[:payment_type], payments) if params[:payment_type].present?
        meta     = { types: payments.distinct(:payment_type).pluck(:payment_type) }
        payments = payments.order(payment_order)

        present(:meta, meta, with: API::V1::Entities::PaymentTypes)
        present(:data, paginate(payments), with: API::V1::Entities::Payment)
      end

      resource :promocodes do
        desc 'Get active promocode for current user.'
        get :active do
          user_promocode  = PromocodesUser.search_actual_promocode_by_user(current_user)
          code = user_promocode.present? ? user_promocode.promocode.code : nil

          { code: code }
        end

        desc 'Add new promocode to user.'
        params { use :promocode_new }
        post do
          add_promocode_service = Services::Promocode::AddToUser.new(current_user, params[:code]).call

          if add_promocode_service.error == Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_EXIST
            fail ActiveRecord::RecordNotFound, I18n.t('promocode.not_exist')
          elsif add_promocode_service.error == Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_VALID
            fail API::V1::Errors::ValidationError.new({'code': [I18n.t('errors.messages.invalid')]})
          elsif add_promocode_service.error == Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ACTUAL
            fail API::V1::Errors::ValidationError.new({'code': [I18n.t('errors.messages.not_actual')]})
          elsif add_promocode_service.error == Services::Promocode::AddToUser::ERROR_PROMOCODE_ALREADY_USED
            fail API::V1::Errors::ValidationError.new({'code': [I18n.t('errors.messages.already_used')]})
          elsif add_promocode_service.error == Services::Promocode::AddToUser::ERROR_PROMOCODE_NOT_ADDED
            fail API::V1::Errors::Users::PromocodeNotAddedError
          end
        end
      end

      desc 'Update password for current user.'
      params { use :user_password_update }
      put :passwords do
        fail API::V1::Errors::Users::NeedSetPasswordError if current_user.uses_default_password
        unless current_user.update_with_password(change_password_params)
          fail API::V1::Errors::ValidationError, current_user.errors
        end

        present(current_user, with: API::V1::Entities::User)
      end

      desc 'Create password for oauth-user.'
      params { use :user_password_create }
      post :passwords do
        # TODO: update OTP methods with check this ability
        fail API::V1::Errors::NotAuthorizedError unless current_user.uses_default_password
        unless current_user.update_attributes(create_password_params)
          fail API::V1::Errors::ValidationError, current_user.errors
        end

        present(current_user, with: API::V1::Entities::User)
      end

      resource :promotokens do
        desc 'Get actual promotoken code'
        get :code do
          code = Promocode.search_promo_token
          present(code, with: API::V1::Entities::Promotoken)
        end

        desc 'Get promo-tokens balance'
        get :balance do
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:promo_token_enabled, :ico)

          TokenTransaction.promo_token_balance_by_user(current_user.id).to_f
        end

        desc 'Generate address for promo-tokens balance.'
        post :address do
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:promo_token_enabled, :ico)

          address = Services::PaymentAddress::PromoTokensAddressGetter.new(user: current_user).call
          fail API::V1::Errors::PromoTokens::GetAddressError if address.nil?

          present(address.currency.to_sym, address, with: API::V1::Entities::PaymentAddress)
        end

        desc 'Get actual address for promo-tokens.'
        get :address do
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)
          fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:promo_token_enabled, :ico)

          address = PaymentAddress.promo_token_adress_by_user(current_user.id)

          present(address.currency.to_sym, address, with: API::V1::Entities::PaymentAddress) if address.present?
        end
      end

      resource :kyc do
        desc 'Get information about KYC for current user.'
        get do
          fail API::V1::Errors::NotAuthorizedError unless Parameter.kyc_verification_enabled?

          present(current_user.kyc_verification, with: API::V1::Entities::KycVerification)
        end

        desc 'Submit new KYC verification.'
        params { use :kyc_create }
        post do
          fail API::V1::Errors::NotAuthorizedError unless Parameter.kyc_verification_enabled?

          icos_id_kyc_verify = Services::IcosId::Verify.new(current_user.id, params)
          icos_id_kyc_verify.call

          case icos_id_kyc_verify.error
          when Services::IcosId::Verify::ERROR_USER_NOT_EXIST
            fail ActiveRecord::RecordNotFound, I18n.t('errors.messages.user_not_exist')
          when Services::IcosId::Verify::ERROR_GET_ICOS_ID_ACCOUNT
            fail API::V1::Errors::IcosId::GetAccountError
          when Services::IcosId::Verify::ERROR_CREATE_ICOS_ID_ACCOUNT
            fail API::V1::Errors::IcosId::CreateAccountError
          when Services::IcosId::Verify::ERROR_SEND_VERIFY
            fail API::V1::Errors::IcosId::SendVerifyError
          when Services::IcosId::Verify::ERROR_ICOS_ID_ALREADY_VERIFIED
            fail API::V1::Errors::IcosId::AlreadyVerifiedError
          when Services::IcosId::Verify::ERROR_ICOS_ID_VERIFY_IN_PROGRESS
            fail API::V1::Errors::IcosId::VerifyInProgressError
          else
            nil
          end
        end
      end
    end

    desc 'Register a new user.'
    params { use :sign_up }
    post :registrations do
      user = User.new(sign_up_params)

      user.skip_confirmation_notification!
      user.save!
      user.send_confirmation_notification_from_api(
        params.fetch(:confirmation_uri, headers.fetch('Referer', nil)),
        params.fetch(:referral_uri, headers.fetch('Referer', nil))
      )

      env['warden'].set_user(user, store: false) if user.confirmed?
      present(user, with: API::V1::Entities::User)
    end

    resource :sessions do
      desc 'Authorize user by email and password.'
      params { use :sign_in }
      post do
        user       = User.find_by(email: sign_in_params[:email])
        unlock_uri = params.fetch(:unlock_uri, headers.fetch('Referer', nil))

        fail API::V1::Errors::Users::LoginError if user.nil?
        unless user.valid_password?(sign_in_params[:password])
          user.increment_failed_attempts!(unlock_uri: unlock_uri)
          fail API::V1::Errors::Users::LoginError
        end

        fail API::V1::Errors::Users::ConfirmationError unless user.confirmed?
        fail API::V1::Errors::Users::LockedError if user.access_locked?

        if user.two_factor_enabled?
          fail API::V1::Errors::OTP::RequiredError if sign_in_params[:otp].blank?
          unless user.consume_otp_attempt!(sign_in_params[:otp])
            user.increment_failed_attempts!(unlock_uri: unlock_uri)
            fail API::V1::Errors::ValidationError.new({'otp': [I18n.t('errors.messages.invalid')]})
          end
        end

        env['warden'].set_user(user, store: false)
        present(user, with: API::V1::Entities::User)
      end

      desc 'To prolong session (get new JWT).'
      put :prolong do
        env['warden'].set_user(current_user, store: false)

        present(current_user, with: API::V1::Entities::User)
      end

      desc 'Make previously issued tokens invalid.'
      delete do
        token = Warden::JWTAuth::HeaderParser.from_env(env)
        Warden::JWTAuth::TokenRevoker.new.call(token)

        status 204
        nil
      end
    end

    desc 'Request a password reset.'
    params { use :password_reset_request }
    post :passwords do
      user              = User.find_by!(email: params[:email])
      edit_password_uri = params.fetch(:edit_password_uri, headers['Referer'])

      user.send_reset_password_instructions_from_api(edit_password_uri)

      status 200
      nil
    end

    desc 'Change password after a reset request.'
    params { use :password_edit }
    put :passwords do
      user = User.reset_password_by_token(password_edit_params)
      fail ActiveRecord::RecordInvalid, user if user.errors.present?

      present(user, with: API::V1::Entities::User)
    end

    desc 'Account confirmations.'
    params { use :confirmation }
    put :confirmations do
      user = User.confirm_by_token(params[:confirmation_token])
      fail ActiveRecord::RecordInvalid, user if user.errors.present?

      present(user, with: API::V1::Entities::User)
    end

    desc 'Repeat confirmation.'
    params { use :confirmation_repeat }
    post :confirmations do
      user = User.find_or_initialize_by(email: params[:email])

      user.errors.add(:email, :not_found) if user.new_record?
      user.errors.add(:email, :already_confirmed) if user.confirmed_at.present?
      fail ActiveRecord::RecordInvalid, user if user.errors.present?

      user.send_confirmation_notification_from_api(
        params.fetch(:confirmation_uri, headers.fetch('Referer', nil)),
        params.fetch(:referral_uri, headers.fetch('Referer', nil))
      )

      status 200
      nil
    end

    desc 'Unlock account.'
    params { use :unlock }
    put :unlocks do
      user = User.unlock_access_by_token(params[:unlock_token])
      fail ActiveRecord::RecordInvalid, user if user.errors.present?
    end
  end
end
