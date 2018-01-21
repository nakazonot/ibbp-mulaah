class API::V1::Invoices < Grape::API
  include API::V1::Defaults
  helpers API::V1::Helpers::Invoices

  resource :invoices do
    desc 'Make invoice.'
    params { use :invoice }
    post do
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:make_deposits, :user_kyc)
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:make_deposits, :stage)
      fail API::V1::Errors::NotAuthorizedError unless current_user.ability.can?(:show_ico_info, :user)

      invoice_form  = Forms::Invoice::CreateForm.new(invoice_params)
      fail ActiveRecord::RecordInvalid, invoice_form unless invoice_form.valid?

      invoice       = Services::Invoiced::InvoiceCreator.new(invoice_form.attributes, current_user).call
      fail API::V1::Errors::Invoices::CreateError if !invoice.present? || !invoice.persisted?

      present(invoice, with: API::V1::Entities::Invoice)
    end

    desc 'Get available country list for Invoice.'
    get :countries do
      ISO3166::Country.translations
    end
  end
end
