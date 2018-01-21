ActiveAdmin.register_page 'Dashboard' do
  page_action :generate_date_ranges

  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    parameters = Parameter.get_all
    range      = range_picker_dates(params[:range])
    statistics = Services::Dashboard::Statistics.new(range[:starting_at], range[:ending_at]).call

    h3 'Users'
    table do
      tr do
        th 'Name'
        th 'Count'
      end
      tr do
        td 'Registered Users Count'
        td link_to(statistics[:users][:registered], admin_users_path)
      end
      tr do
        td 'Token Holders'
        td link_to(statistics[:users][:token_holders], admin_users_path(scope: 'tokenholders'))
      end
      tr do
        td 'Deposited Only'
        td link_to(statistics[:users][:deposited_only], admin_users_path(scope: 'deposited_only'))
      end
    end

    hr

    h3 'Payment Addresses'
    statistics[:payment_addresses].each do |payment_address_type, row|
      next if !Promocode.promo_token_enabled? && PaymentAddressType::PROMO_TOKENS == payment_address_type
      h4 PaymentAddressType.description(payment_address_type)
      row.each do |payment_system, currencies|
        h5 PaymentSystemType.description(payment_system)
        table do
          tr do
            th 'Currency'
            th 'Used'
            th 'Unused'
          end

          currencies.each do |currency, info|
            tr do
              td currency
              td info[:used]
              td info[:unused]
            end
          end
        end
      end
    end

    hr

    h3 'Transactions'
    form id: 'range-picker-form' do |f|
      f.input type: :text,
              id: 'range-picker',
              name: 'range',
              placeholder: 'Select date range',
              'data-starting-at': range[:starting_at],
              'data-ending-at': range[:ending_at]
      button id: 'range-clear' do
        'Clear'
      end
    end

    h4 'Tokens'
    table do
      tr do
        th 'Name'
        th 'Amount'
        th "Amount in #{parameters['coin.rate_currency']}"
      end
      tr do
        td 'Purchased'
        td coins_number_format(statistics[:tokens][:purchased][:amount])
        td ico_currency_number_format(statistics[:tokens][:purchased][:worth])
      end
      tr do
        td 'Bonus'
        td coins_number_format(statistics[:tokens][:bonus][:amount])
        td ico_currency_number_format(statistics[:tokens][:bonus][:worth])
      end
      if User.new.ability.can? :referral_system, :tokens
        tr do
          td 'Referral'
          td coins_number_format(statistics[:tokens][:referral][:amount])
          td ico_currency_number_format(statistics[:tokens][:referral][:worth])
        end
      end
      tr do
        td 'Balance'
        td coins_number_format(statistics[:tokens][:balance][:amount])
        td ico_currency_number_format(statistics[:tokens][:balance][:worth])
      end
      tr do
        td 'Refund'
        td coins_number_format(statistics[:tokens][:refund][:amount])
        td ico_currency_number_format(statistics[:tokens][:refund][:worth])
      end
      tr do
        td 'Transferred'
        td coins_number_format(statistics[:tokens][:transfer][:amount])
        td ico_currency_number_format(statistics[:tokens][:transfer][:worth])
      end
    end

    h4 'Raised'
    table do
      tr do
        th 'Currency'
        th 'Amount'
        th "Amount in #{parameters['coin.rate_currency']}"
        if User.new.ability.can? :referral_system, :balance
          th 'Referral amount'
          th "Referral amount in #{parameters['coin.rate_currency']}"
        end
      end

      statistics[:raised][:currencies].each do |currency, info|
        tr do
          td currency
          td currency_number_format(info[:amount_in_currency], currency)
          td ico_currency_number_format(info[:amount_in_system_currency])
          if User.new.ability.can? :referral_system, :balance
            td currency_number_format(info[:referral_amount_in_currency], currency)
            td ico_currency_number_format(info[:referral_amount_in_system_currency])
          end
        end
      end

      tr class: 'tr-total' do
        td do
          b 'TOTAL'
        end
        td '-'
        td do
          b ico_currency_number_format(statistics[:raised][:total])
        end
        if User.new.ability.can? :referral_system, :balance
          td '-'
          td do
            b ico_currency_number_format(statistics[:raised][:total_referral])
          end
        end
      end
    end
  end

  controller do
    def generate_date_ranges
      ajax_ok(Services::Dashboard::GenerateRanges.new.call)
    end
  end
end
