ActiveAdmin.register IcoStage do
  menu priority: 50
  config.batch_actions = false

  config.sort_order = 'date_start_asc'

  permit_params :name, :date_start, :date_end, :coin_price, :min_payment_amount, :prohibit_purchase_tokens, 
    :buy_token_promocode_id, :tokens_limit, :prohibit_make_deposits

  index do
    unless IcoStage.ico_dates_valid?
      div class: 'stages-alert' do
        'Attention! ICO is closed now because there is a gap or an overlapping in ICO periods.'
      end
    end
    column :name
    column :date_start
    column :date_end
    column :coin_price do |ico_stage|
      ico_currency_number_format(ico_stage.coin_price)
    end
    column :min_payment_amount
    column "Tokens volume limit" do |ico_stage|
      ico_stage.tokens_limit
    end
    column :prohibit_make_deposits
    column :prohibit_purchase_tokens
    column "Enable purchase promocode" do |ico_stage|
      ico_stage.buy_token_promocode.code if ico_stage.buy_token_promocode.present?
    end
    actions default: true, dropdown: true do |ico_stage|
      item "Bonus preferences", admin_ico_stage_bonus_preferences_path(ico_stage)
    end
  end

  form do |f|
    f.inputs 'ICO Stage' do
      f.input :name, label: 'ICO stage name'
      div class: 'input-group date' do
        f.input :date_start, as: :string, label: 'Start date'
      end
      div class: 'input-group date' do
        f.input :date_end, as: :string,  label: 'End date'
      end
      f.input :coin_price, as: :string, label: 'Coin price'
      f.input :min_payment_amount, as: :string, label: 'Minimum payment amount'
      f.input :tokens_limit, as: :string, label: 'Tokens volume limit<br><span class="info">Leave blank for unlimited distribution</span>'.html_safe, input_html: {maxlength: 18}
      f.input :prohibit_make_deposits, label: 'Prohibit the make of deposits'
      f.input :prohibit_purchase_tokens, label: 'Prohibit the purchase of tokens'
      f.input :buy_token_promocode_id, as: :select, collection: Promocode.all.order(:code).pluck(:code, :id), label: 'Enable purchase promocode'
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :date_start
      row :date_end
      row :coin_price do |ico_stage|
        ico_currency_number_format(ico_stage.coin_price)
      end
      row :min_payment_amount
      row "Tokens volume limit" do |ico_stage|
        ico_stage.tokens_limit
      end
      row "Bonus preferences" do |ico_stage|
        res = []
        ico_stage.bonus_preferences.order(:bonus_percent).each do |bonus|
          res << "#{percent_format(bonus.bonus_percent)} Bonus for purchase ≥ #{ico_currency_format(bonus.min_investment_amount)} <br>"
        end
        res << link_to("Bonus preferences", admin_ico_stage_bonus_preferences_path(ico_stage))
        res.join.html_safe
      end
      row :prohibit_make_deposits
      row :prohibit_purchase_tokens
      row "Enable purchase promocode" do |ico_stage|
        ico_stage.buy_token_promocode.code if ico_stage.buy_token_promocode.present?
      end
      row :created_at
      row :updated_at
    end
  end

  filter :name

  controller do
    def destroy
      super
      flash[:notice] = 'ICO Stage was successfully deleted.'
    end

    def create
      super do |format|
        redirect_to admin_ico_stages_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_ico_stages_path and return if resource.valid?
      end
    end
  end
end