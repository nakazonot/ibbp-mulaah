ActiveAdmin.register_page 'User transactions' do
  
  menu priority: 21, label: 'User transactions'

  content title: 'User transactions' do
    filter = params['filter'].to_s.strip

    div do
      form_for :payment, { url: admin_user_transactions_path, html: {  class: 'display-flex' }, method: :get } do |f|
        f.input :filter, name: 'filter', value: filter, placeholder: 'User E-Mail or Payment Address or Referral UUID', class: 'input-admin-big'
        f.input :submit, value: 'OK', type: :submit, class: 'button-admin-big'
      end
    end

    if filter.present? && (user = User.find_by_filter(filter)).present?
      payments = Payment.by_user(user&.id).order(:id)
      addresses = PaymentAddress.with_deleted.by_user(user.id)
      h3 'User:'
      h5 link_to user.email, admin_user_path(user.id)
      h3 'Adresses:'
      addresses.each do |address|
        html_address = "#{address.currency}: "
        url = Services::PaymentAddress::GetUrl.new(address).call
        if url.present?
          html_address += "<a href=\"#{url}\" target=\"_blank\">#{address.payment_address}</a>" 
        else
          html_address += address.payment_address
        end
        dest_tag = address.dest_tag.present? ? "dest_tag: #{address.dest_tag}, " : ""
        html_address += " (#{dest_tag}#{PaymentSystemType.description(address.payment_system)}"
        html_address += "/#{PaymentAddressType.description(address.address_type)}" if address.address_type == PaymentAddressType::PROMO_TOKENS
        html_address += ")"
        if address.deleted?
          html_address = "<span data-toggle=\"tooltip\" data-placement=\"top\" title=\"Payment Address was deleted\"><s>#{html_address}</s></span>"
        end
        html_address
        h5 html_address.html_safe
      end

      h3 'Transactions'
      table do
        tr style: "height: 30px;" do
          th 'Payment ID'
          th 'Date'
          th 'Amount'
          th 'Currency'
          th 'Exchange rate'
          th 'Tokens issued'
          th 'System'
          th 'Payment Type'
          th 'Actions'
        end
        get_link_service = Services::Payment::GetLink.new
        payments.each do |payment|
          tr do
            td payment.id
            td date_payment_history(payment.created_at)
            td get_link_service.call(payment)
            td payment.currency_buyer
            td payment.iso_coin_rate.to_f > 0 ? original_number_format(payment.iso_coin_rate) : ''
            td payment.iso_coin_amount.to_f > 0 ? original_number_format(payment.iso_coin_amount) : ''
            td payment.system ? "Yes" : "No"
            td payment.payment_type
            td link_to "view", admin_payment_path(payment)
          end
        end
      end
    else
      h4 'User not Found'
    end
  end

end
