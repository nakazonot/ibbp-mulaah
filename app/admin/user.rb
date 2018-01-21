include ApplicationHelper

ActiveAdmin.register User do
  config.batch_actions = false
  config.action_items.delete_if { |item| item.name == :destroy && item.display_on?(:show) }

  menu label: 'Customers', priority: 20, if: ->{ can? :view_index, User }

  permit_params :role, :email, :phone, :btc_wallet, :eth_wallet, :name, :kyc_date, :kyc_result

  scope :all, :default => true
  scope 'Tokenholders' do |users|
    users.having("SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}) > 0")
  end
  scope 'Deposited only' do |users|
    users.where('users.id IN (?)', User.deposited_only.keys)
  end
  scope 'Without tokens' do |users|
    users.having("COALESCE(SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}), 0) <= 0")
  end

  action_item :import_csv_button, only: :index do
    link_to('Import From CSV', import_csv_admin_users_path) if can?(:create, User)
  end

  action_item :import_kyc_csv_button, only: :index do
    link_to('Import KYC From CSV', import_kyc_csv_admin_users_path) if can?(:create, User) && can?(:input, :kyc)
  end

  action_item :update_kyc, only: :show do
    if Parameter.kyc_verification_enabled? && resource.kyc_verification
      link_to('Update KYC', update_kyc_admin_user_path(resource))
    end
  end

  collection_action :import_csv_form, method: :post
  collection_action :import_csv, method: :get do
    return redirect_to admin_users_path, alert: "You do not have permission" unless can?(:create, User)
  end
  collection_action :import_kyc_csv_form, method: :post
  collection_action :import_kyc_csv, method: :get do
    return redirect_to admin_users_path, alert: "You do not have permission" if !can?(:create, User) || !can?(:input, :kyc)
  end

  member_action :update_kyc, method: :get

  index title: 'Customers', if: false do
    column :id
    column 'Registered at' do |user|
      user.created_at
    end
    column :email
    column :name

    if Parameter.kyc_verification_enabled?
      column 'KYC Status', sortable: 'kyc_verifications.status' do |user|
        KycStatusType.description(user.kyc_verification&.status)
      end
    elsif can?(:input, :kyc)
      column :kyc_date
      column :kyc_result
    end

    column 'Transactions' do |user|
      link_to(user.transactions_total, admin_payments_path('q[user_email_contains]': user.email))
    end
    column 'Bought', :sortable => 'coins_total' do |user|
      coins_number_format(user.coins_total)
    end
    actions defaults: false, dropdown: true do |user|
      if can?(:read, user)
        item 'View', admin_user_path(id: user.id), class: 'member_link'
      end
      if can?(:update, user)
        item 'Edit', edit_admin_user_path(id: user.id), class: 'member_link'
      end
      if can?(:destroy, user)
        item 'Delete', admin_user_path(id: user.id), class: 'member_link btn-delete-user', data: {
          method: :delete,
          confirmed: false,
          'user-id': user.id,
          'user-email': user.email
        }
      end
      item 'Payment addresses', admin_payment_addresses_path('q[user_email_equals]' => user.email, commit: 'Filter')
      if can?(:referral_system_enabled, :ico)
        item 'Referrals', admin_users_path('q[referral_id_equals]' => user.id, commit: 'Filter')
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Make deposit')
        item 'Make Deposit', admin_make_deposit_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Refund')
        item 'Refund', admin_refund_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Buy tokens')
        item 'Buy tokens', admin_buy_tokens_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Add tokens')
        item 'Add tokens', admin_add_tokens_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Refund tokens')
        item 'Refund tokens', admin_refund_tokens_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:manage, ActiveAdmin::Page, name: 'Tokens transfer')
        item 'Tokens transfer', admin_tokens_transfer_new_path(user_id: user.id), class: 'member_link'
      end
      if can?(:confirm, user)
        item 'Activate', confirm_admin_user_path(id: user.id), class: 'member_link btn-activate-user', data: {
          confirmed: false,
          'user-id': user.id,
          'user-email': user.email
        }
      end
      item "User Parameters", admin_user_user_parameters_path(user)
    end
    div do
      render 'modal_user_delete'
      render 'modal_user_activate'
    end
  end

  filter :email
  filter :referral_id, label: 'Referral link publisher ID'
  filter :referral_uuid, label: 'Referral uuid'
  filter :kyc_result, if: proc { can?(:input, :kyc) }

  csv do
    coin_precision_parameter = Parameter.get_all['coin.precision']

    column :id
    column :email
    column :phone
    column :name
    if Parameter.kyc_verification_enabled?
      column 'KYC Status' do |user|
        KycStatusType.description(user.kyc_verification&.status)
      end
      column 'KYC Verified At' do |user|
        user.kyc_verification&.verified_at
      end
    elsif can?(:input, :kyc)
      column :kyc_date
      column :kyc_result
    end
    column :eth_wallet if can?(:input, :eth_wallet)
    column :btc_wallet if can?(:input, :btc_wallet)
    column 'Transactions' do |user|
      user.transactions_total
    end
    column 'Bought' do |user|
      coin_floor(user.coins_total, coin_precision_parameter)
    end
    column 'Referral link' do |user|
      referral_link(user)
    end
    column 'Registered at' do |user|
      user.created_at
    end
    column 'Account confirmed at' do |user|
      user.confirmed_at
    end
    column 'Registration IP' do |user|
      user.sign_up_ip
    end
    column 'Registration country' do |user|
      user.sign_up_country
    end
    column :role
  end

  show do |user|
    attributes_table do
      row :id
      row :email
      row :phone
      row :name

      if Parameter.kyc_verification_enabled?
        row 'KYC Verification Status' do
          content_tag(:span, KycStatusType.description(user.kyc_verification&.status), class: "kyc-status #{user.kyc_verification&.status}")
        end
        if user.kyc_verification&.verified_at.present?
          row 'KYC Verified At' do
            user.kyc_verification&.verified_at
          end
        end
      elsif can?(:input, :kyc)
        row :kyc_date
        row :kyc_result
      end

      row :eth_wallet if can?(:input, :eth_wallet)
      row :btc_wallet if can?(:input, :btc_wallet)
      row 'Transactions' do
        link_to(user.transactions_total, admin_payments_path('q[user_email_contains]': user.email))
      end
      row 'Bought' do
        coins_number_format(user.coins_total)
      end
      row 'Referral link' do
        referral_link(user)
      end
      row 'Promocode' do
        PromocodesUser::search_actual_promocodes_by_user(user.id).each  do |user_promocode|
          div link_to("##{user_promocode.promocode.id} #{user_promocode.promocode.code}", admin_promocode_path(user_promocode.promocode)).html_safe + " #{user_promocode.promocode_property})"
        end
        nil
      end
      row 'Registered at' do
        user.created_at
      end
      row 'Account confirmed at' do
        user.confirmed_at
      end
      row 'Last sign in at' do
        user.last_sign_in_at
      end
      row 'Sign in count' do
        user.sign_in_count
      end
      row 'Registration IP' do
        user.sign_up_ip
      end
      row 'Registration country' do
        user.sign_up_country
      end
      row 'Referral link publisher' do
        user.referral&.email
      end
      row 'User balance' do
        Payment.balances_by_user(user).each do |currency, balance|
          div "#{currency}: #{currency_number_format(balance, currency)}"
        end
        nil
      end
      row :role
      if user.is_oauth_sign_up
        row :oauth_email_confirmed_at
      end
      row :tracking_labels
    end
    if Parameter.kyc_verification_enabled? && user.kyc_verification
      panel "KYC Verification" do
        attributes_table_for user.kyc_verification do
          row :first_name
          row :middle_name
          row :last_name
          row :phone
          row t('activerecord.attributes.kyc_verification.dob') do |kyc|
            kyc.dob
          end
          row :gender
          row :address do |kyc|
            unless kyc.address.blank?
              addresses = []
              kyc.address.each{ |title, address| addresses << address if address.present? }
              addresses.join("<br>").html_safe
            end
          end
          row :state
          row :citizenship
          row :city
          row :country_code
          row :document_number
          row :deny_reason
        end
      end
    end
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :email
        f.input :phone
        f.input :name
        f.input :eth_wallet if can?(:input, :eth_wallet)
        f.input :btc_wallet if can?(:input, :btc_wallet)
      end
      if can?(:input, :kyc)
        div class: 'input-group date' do
          f.input :kyc_date, as: :string
        end
      end
      f.input :kyc_result if can?(:input, :kyc)
      f.input :role,
              as: :select,
              collection: [
                [I18n.t('roles.user'), User::ROLE_USER],
                [I18n.t('roles.admin'), User::ROLE_ADMIN],
                [I18n.t('roles.admin_read_only'), User::ROLE_ADMIN_READ_ONLY],
                [I18n.t('roles.support'), User::ROLE_SUPPORT]
              ],
              selected: f.object.role.present? ? f.object.role : User::ROLE_USER,
              include_blank: false
    end
    f.actions
  end

  member_action :confirm, method: :get do
    user = User.find(params[:id])
    return redirect_back(fallback_location: admin_users_path) if user.nil? || !can?(:confirm, user)

    if user.confirm
      flash[:notice] = t('notice.messages.user_activated', user_id: user.id)
    else
      flash[:error] = t('errors.messages.user_not_activated', user_id: user.id)
    end

    redirect_back(fallback_location: admin_users_path)
  end

  controller do
    def scoped_collection
      User.customers
          .includes(:kyc_verification)
          .group('kyc_verifications.id')
          .joins('LEFT JOIN kyc_verifications ON users.id = kyc_verifications.user_id')
    end

    def index
      return redirect_to root_path, alert: 'You are not authorized to perform this action.' unless can? :view_index, User
      super
    end

    def create
      build_resource
      resource.password               = "#{SecureRandom.hex(12).upcase}#{SecureRandom.hex(12)}"
      resource.registration_agreement = true
      resource.validated_scopes       = [:phone_require, :eth_wallet_require, :btc_wallet_require]
      resource.skip_welcome_email     = true
      resource.skip_confirmation!
      super do |format|
        if resource.valid?
          resource.send_reset_password_instructions_register_from_admin
          redirect_to collection_url
          return
        end
      end
    end

    def import_csv_form
      return redirect_to admin_users_path, alert: "You do not have permission" unless can?(:create, User)
      return redirect_to import_csv_admin_users_path, alert: "No file selected" if params[:import_csv].blank?
      csv_file = params[:import_csv][:file]
      errors = Services::Users::ImportCsv.new(csv_file).call
      return redirect_to import_csv_admin_users_path, alert: errors[:flash_error] if errors[:flash_error].present?
      @validation_errors = errors[:validation_errors]
      return redirect_to admin_users_path, notice: "Users were successfully imported" if @validation_errors.blank?
      flash.now[:warning] = "Import was successful, but some users were not imported due to validation errors"
      render "admin/users/import_csv"
    end

    def import_kyc_csv_form
      return redirect_to admin_users_path, alert: "You do not have permission" unless can?(:create, User)
      return redirect_to import_kyc_csv_admin_users_path, alert: "No file selected" if params[:import_kyc_csv].blank?
      csv_file = params[:import_kyc_csv][:file]
      errors = Services::Users::ImportKycCsv.new(csv_file).call
      return redirect_to import_kyc_csv_admin_users_path, alert: errors[:flash_error] if errors[:flash_error].present?
      @validation_errors = errors[:validation_errors]
      return redirect_to admin_users_path, notice: "Users were successfully imported" if @validation_errors.blank?
      flash.now[:warning] = "Import was successful, but some users were not imported due to validation errors"
      render "admin/users/import_kyc_csv"
    end

    def update_kyc
      return redirect_to admin_users_path unless Parameter.kyc_verification_enabled?
      @user = User.find(params[:id])
      @kyc = @user.kyc_verification
      return redirect_to admin_users_path, alert: "User doesn't have KYC verification" if @kyc.blank?
      return redirect_to admin_users_path, alert: "You cannot verify this users's KYC" unless @kyc.in_progress? || @kyc.rejected?

      result = Services::IcosId::UpdateKycStatus.new(@kyc)
      result.call

      if result.error.blank?
        return redirect_to admin_user_path(@user), notice: 'KYC status updated successfully.'
      else
        return redirect_to admin_user_path(@user), alert: 'Failed to update KYC status.'
      end
    end
  end
end
