ActiveAdmin.register_page "Tokens transfer" do

  menu false

  controller do
    layout 'active_admin'
  end

  page_action :new, method: :get do
    @payment = Forms::Payment::CreateFormForTokensTransfer.new(user_id: params[:user_id])
    render "create_form"
  end

  page_action :create, method: :post do
    @user = User.find(params[:payment][:user_id])
    @payment = Forms::Payment::CreateFormForTokensTransfer.new(params.require(:payment).permit(:user_id, :coin_amount, :description, :transaction_id))
    if @payment.valid?
      Payment.create(@payment.get_payment_data.merge(created_by_user_id: current_user.id).merge(Services::SystemInfo::RequestInfo.new(request).call))
      return redirect_to admin_users_path
    end
    render "create_form"
  end

end