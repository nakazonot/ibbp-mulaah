ActiveAdmin.register User, as: "User Tokens" do
  menu label: 'User tokens', priority: 22, if: ->{ can? :view_index, User }

  scope :all, :default => true
  scope 'Tokenholders' do |users|
    users.having("SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}) > 0")
  end
  scope 'Without tokens' do |users|
    users.having("COALESCE(SUM(#{Payment.query_for_iso_coin_amount(Payment::PAYMENT_TYPES_TOKENS, Payment::PAYMENT_TYPES_REFUND_TOKENS)}), 0) <= 0")
  end

  index title: 'Users' do
    column :email
    column :name
    column :eth_wallet if can?(:input, :eth_wallet)
    column :btc_wallet if can?(:input, :btc_wallet)
    column :kyc_date   if can?(:input, :kyc)
    column :kyc_result if can?(:input, :kyc)
    column 'Tokens', :sortable => 'coins_total' do |user|
      coins_number_format(user.coins_total)
    end
  end

  filter :email

  csv do
    coin_precision_parameter = Parameter.get_all['coin.precision']

    column :email
    column :name
    column :eth_wallet if can?(:input, :eth_wallet)
    column :btc_wallet if can?(:input, :btc_wallet)
    column :kyc_date   if can?(:input, :kyc)
    column :kyc_result if can?(:input, :kyc)
    column 'Tokens' do |user|
      coin_floor(user.coins_total, coin_precision_parameter)
    end
  end

  show do |user|
    attributes_table do
      row :email
      row :name
      row :eth_wallet if can?(:input, :eth_wallet)
      row :btc_wallet if can?(:input, :btc_wallet)
      row :kyc_date   if can?(:input, :kyc)
      row :kyc_result if can?(:input, :kyc)
      row 'Tokens' do
        coins_number_format(user.coins_total)
      end
    end
  end

  controller do
    actions :all, :except => [:new, :create, :edit, :update, :destroy]

    def scoped_collection
      User.customers
    end
  end
end
