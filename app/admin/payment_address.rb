ActiveAdmin.register PaymentAddress do
  menu label: 'Payment Addresses', priority: 22, if: ->{ can? :view_index, PaymentAddress }

  config.sort_order = 'currency_asc'

  index title: 'Payment Addresses' do
    column 'Address', :payment_address
    column :currency
    column :payment_system do |payment_address|
      PaymentSystemType.description(payment_address.payment_system)
    end
    column :address_type do |payment_address|
      PaymentAddressType.description(payment_address.address_type)
    end
    column :user, :sortable => 'users.email' do |payment_address|
      link_to payment_address.user.email, admin_user_path(payment_address.user) if payment_address.user.present?
    end
    actions
  end

  filter :user_email, as: :string, filters: [:equals, :contains]
  filter :payment_address, as: :string

  show do |payment_address|
    attributes_table do
      row 'ID' do
        payment_address.id
      end
      row 'Address' do
        payment_address.payment_address
      end
      row 'Currency' do
        payment_address.currency
      end
      row 'Pubkey' do
        payment_address.pubkey
      end
      row 'Dest Tag' do
        payment_address.dest_tag
      end
      row 'User' do
        payment_address.user&.email
      end
      row 'PaymentSystem' do
        PaymentSystemType.description(payment_address.payment_system)
      end
      row 'AddressType' do
        PaymentAddressType.description(payment_address.address_type)
      end
      row 'Created At' do
        payment_address.created_at
      end
    end
  end

  controller do
    def scoped_collection
      PaymentAddress.joins(:user)
    end

    def index
      return redirect_to root_path, alert: 'You are not authorized to perform this action.' unless can? :view_index, PaymentAddress
      super
    end
  end
end