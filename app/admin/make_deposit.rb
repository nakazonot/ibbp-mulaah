ActiveAdmin.register_page 'Make Deposit' do

  menu false

  controller do
    layout 'active_admin'
  end

  page_action :new, method: :get do
    @payment = Forms::Payment::CreateForm.new(user_id: params[:user_id])
    render "create_form"
  end

  page_action :create, method: :post do
    @payment = Forms::Payment::CreateForm.new(params.require(:payment).permit(:user_id, :amount, :currency, :description, :add_bonus))
    if @payment.valid?
      Services::Coin::BalancePaymentCreator.new(@payment.get_payment_data, created_by_user: current_user, request: request).call
      return redirect_to admin_users_path
    end
    render "create_form"
  end

end