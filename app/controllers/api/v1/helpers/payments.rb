module API::V1::Helpers::Payments
  extend Grape::API::Helpers

  SORTABLE_ATTRIBUTES = {
    id:                  :id,
    created_at:          :created_at,
    type:                :payment_type,
    amount:              :amount_buyer,
    currency:            :currency_buyer,
    ico_currency_amount: :ico_currency_amount,
    tokens:              :iso_coin_amount
  }

  params :payments_filter do
    optional :payment_type,           type: String,   desc: 'Payment type (purchase, balance, etc)', payment_type: true
    optional :order_column,           type: String,   desc: 'Column to be used for sorting', payments_order_column: true
    optional :order_direction,        type: String,   desc: 'Sorting direction (desc, asc).', order_direction: true
  end

  def payment_order
    order_direction  = params[:order_direction].present? ? params[:order_direction].to_sym : :asc
    order_column     = payment_order_column.present? ? payment_order_column : :id

    { "#{order_column}": order_direction }
  end

  def payment_order_column
    SORTABLE_ATTRIBUTES[params[:order_column].to_sym] if params[:order_column].present?
  end
end
