ActiveAdmin.register_page "Refund" do

  menu false

  controller do
    layout 'active_admin'
  end

  page_action :new, method: :get do
    @payment = Forms::Payment::CreateFormRefund.new(user_id: params[:user_id])
    render "create_form"
  end

  page_action :create, method: :post do
    @payment = Forms::Payment::CreateFormRefund.new(params.require(:payment).permit(:user_id, :amount, :currency, :description))
    if @payment.valid?
      Payment.create(@payment.get_payment_data.merge(created_by_user_id: current_user.id).merge(Services::SystemInfo::RequestInfo.new(request).call))
      return redirect_to admin_users_path
    end
    render "create_form"
  end

end