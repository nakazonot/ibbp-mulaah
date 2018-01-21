ActiveAdmin.register Payment do
  menu label: 'Transactions', priority: 10, if: ->{ can? :view_index, Payment }

  index title: 'Transactions' do
    column 'ID' do |payment|
      payment.id
    end
    column 'Date' do |payment|
      payment.created_at
    end
    column :user do |payment|
      payment.user.deleted? ? payment.user.email : link_to(payment.user.email, admin_user_path(payment.user))
    end
    column 'Country' do |payment|
      payment.country
    end
    column 'Lang' do |payment|
      payment.lang
    end
    column 'Amount' do |payment|
      original_number_format(payment.amount_buyer) if payment.amount_buyer.to_f > 0
    end
    column 'Currency' do |payment|
      payment.currency_buyer
    end
    column 'Exchange rate' do |payment|
      "#{original_number_format(payment.iso_coin_rate)}" if payment.iso_coin_rate.to_f > 0
    end
    column 'Tokens issued' do |payment|
      original_number_format(payment.iso_coin_amount) if payment.iso_coin_amount.to_f > 0
    end
    column 'System' do |payment |
      payment.system
    end
    column 'Payment type' do |payment|
      raw = "#{payment.payment_type} #{ApplicationHelper.admin_pending_transaction(payment)}"
      raw += "<br/>" + link_to("Promocode: ##{payment.promocodes_user.promocode.id} #{payment.promocodes_user.promocode.code}", admin_promocode_path(payment.promocodes_user.promocode)) if payment.promocodes_user.present?
      raw.html_safe
    end
    actions defaults: true do |payment|
      item('Contract', contract_agreement_path(payment.buy_tokens_contract.uuid, format: :pdf, download_url: true), class: 'member_link') if payment.buy_tokens_contract&.uuid.present?
      item('Invoice', payment.invoice.pdf_url, class: 'member_link') if payment.invoice.present? && payment.invoice.pdf_url.present?
    end
  end

  filter :user_email, as: :string
  filter :promocodes_user_promocode_code, as: :string, label: 'Promocode'
  filter :country, as: :select, collection: -> { Payment.countries }
  filter :lang, as: :select, collection: -> { Payment.languages }
  filter :payment_type, as: :select, collection: -> { Payment.payment_types }
  filter :transaction_id, as: :string

  csv do
    column :id
    column 'User ID' do |payment|
      payment.user_id
    end
    column 'User Email' do |payment|
      payment.user.email
    end
    column 'User Country' do |payment|
      payment.user.sign_up_country if payment.user.sign_up_country != '--'
    end
    column 'Amount' do |payment|
      original_number_format(payment.amount_buyer) if payment.amount_buyer.to_f > 0
    end
    column 'Currency' do |payment|
      payment.currency_buyer
    end
    column 'Tokens Issued' do |payment|
      original_number_format(payment.iso_coin_amount) if payment.iso_coin_amount.to_f > 0
    end
    column 'Bonus percent' do |payment|
      percent_number_format(payment.bonus_percent) if payment.bonus_percent.present?
    end
    column 'Transaction ID' do |payment|
      payment.transaction_id
    end
    column 'Payment address' do |payment|
      payment.payment_address
    end
    column 'Payment Type' do |payment|
      payment.payment_type
    end
    column 'Payment system' do |payment|
      PaymentSystemType.description(payment.payment_system)
    end
    column 'Payment Status' do |payment|
      payment.status
    end
    column 'Country' do |payment|
      payment.country
    end
    column 'Date' do |payment|
      payment.created_at
    end
    column 'Description' do |payment|
      payment.description
    end
    column 'Parent Transaction ID' do |payment|
      payment.parent_payment_id
    end
    column 'System' do |payment|
      payment.system
    end
    column 'Created by' do |payment|
      if Payment::PAYMENT_TYPES_CAN_BE_CREATED_BY_USER.include? payment.payment_type
        payment.created_by_user.present? ? 'Admin' : 'User'
      end
    end
    column 'Created by Admin' do |payment|
      payment.created_by_user.email if payment.created_by_user.present?
    end
  end

  show do |payment|
    attributes_table do
      row 'ID' do
        payment.id
      end
      row :user do
        payment.user.deleted? ? payment.user.email : link_to(payment.user.email, admin_user_path(payment.user))
      end
      row 'User Country' do
        payment.user.sign_up_country if payment.user.sign_up_country != '--'
      end
      row 'IP' do
        payment.ip
      end
      row 'Country' do
        payment.country
      end
      row 'Lang' do
        payment.lang
      end
      row 'Amount' do
        original_number_format(payment.amount_buyer) if payment.amount_buyer.to_f > 0
      end
      row 'Currency' do
        payment.currency_buyer
      end
      row 'Exchange rate' do
        original_number_format(payment.iso_coin_rate) if payment.iso_coin_rate.to_f > 0
      end
      row 'Tokens issued' do
        original_number_format(payment.iso_coin_amount) if payment.iso_coin_amount.to_f > 0
      end
      row 'Bonus percent' do
        percent_format(payment.bonus_percent) if payment.bonus_percent.present?
      end
      row 'Transaction ID' do
        payment.transaction_id
      end
      row 'Payment address' do
        payment.payment_address
      end
      row 'Payment type' do
        payment.payment_type
      end
      row 'Payment system' do
        PaymentSystemType.description(payment.payment_system)
      end
      row 'Payment Status' do |payment|
        payment.status
      end
      row 'Created by' do
        payment.created_by_user.email if payment.created_by_user.present?
      end
      row 'System' do
        payment.system
      end
      row 'Date' do
        payment.created_at
      end
      row 'Description' do
        desc = payment.description.to_s
        if payment.parent_payment.present?
          desc += "<br/>" if desc.present?
          desc += link_to('Parent Payment', admin_payment_path(payment.parent_payment))
        end
        if payment.promocodes_user.present?
          desc += "<br/>" if desc.present?
          desc += link_to("Promocode: ##{payment.promocodes_user.promocode.id} #{payment.promocodes_user.promocode.code}", admin_promocode_path(payment.promocodes_user.promocode)) + " #{payment.promocodes_user.promocode_property})"
        end
        desc.html_safe
      end
    end
  end

  controller do
    def index
      return redirect_to root_path, alert: 'You are not authorized to perform this action.' unless can? :view_index, Payment
      super
    end
  end
end
