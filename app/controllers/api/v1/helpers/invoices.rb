module API::V1::Helpers::Invoices
  extend Grape::API::Helpers

  params :invoice do
    requires :full_name,   type: String, desc: 'Full name'
    requires :amount,      type: Float,  desc: 'Amount in USD'
    optional :phone,       type: String, desc: 'Phone'
    optional :county,      type: String, desc: 'Country code'
    optional :state,       type: String, desc: 'State'
    optional :city,        type: String, desc: 'City'
    optional :address,     type: String, desc: 'Address'
    optional :postal_code, type: String, desc: 'Postal code'
  end

  def invoice_params
    ActionController::Parameters.new(params).permit(
      :full_name,
      :amount,
      :phone,
      :county,
      :state,
      :city,
      :address,
      :postal_code
    )
  end
end
