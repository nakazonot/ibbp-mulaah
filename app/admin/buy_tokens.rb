ActiveAdmin.register_page "Buy tokens" do

  menu false

  controller do
    layout 'active_admin'
  end

  page_action :new, method: :get do
    @contract = Forms::BuyTokensContract::CreateForm.new(user_id: params[:user_id])
    render "create_form"
  end

  page_action :create, method: :post do
    @user = User.find(params[:contract][:user_id])
    @contract = Forms::BuyTokensContract::CreateForm.new(params.require(:contract).permit(:user_id, :coin_amount, :coin_price, :coin_rate, :currency, :description, :add_bonus))
    if @contract.valid?
      contract = Services::Coin::ContractCreator.new(@contract.get_contract_data, @user, from_admin: true, disable_bonus: !@contract.add_bonus).call
      if contract[:error].blank?
        Services::Coin::CoinCreator.new(
          contract,
          created_by_user_id:  current_user.id,
          payment_description: @contract.description,
          disable_bonus:       !@contract.add_bonus,
          request:             request
        ).call
        return redirect_to admin_users_path
      else
        flash.now[:alert] = contract[:error] if contract[:error].present?
      end
    end
    render "create_form"
  end

end