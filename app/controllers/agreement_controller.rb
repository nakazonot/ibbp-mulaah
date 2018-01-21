class AgreementController < ApplicationController
  # def terms_of_services
  #   path = Rails.root.join('docs', 'terms_of_services-tokensale.pdf').to_s
  #   send_file(path, type: 'application/pdf', disposition: 'inline')
  # end

  def token_purchase
    contract_uuid   = params.fetch(:contract_uuid, nil)
    @contract       = BuyTokensContract.find_by!(uuid: contract_uuid)

    respond_to do |format|
      format.pdf do
        data = PDFKit.new(contract_agreement_url(format: :html)).to_pdf
        pdf_params = {
          type: 'application/pdf'
        }
        pdf_params[:disposition] = 'inline' if params[:download_url].blank?
        send_data(data, pdf_params)
      end
      format.html do
        # dates = [
        #   { start: '2017-08-02 12:00:00PM PDT'.in_time_zone, end: '2017-08-09 12:00:00PM PDT'.in_time_zone },
        #   { start: '2017-08-09 12:00:00PM PDT'.in_time_zone, end: '2017-08-09 03:00:00PM PDT'.in_time_zone },
        #   { start: '2017-08-09 03:00:00PM PDT'.in_time_zone, end: '2017-08-15 12:00:00PM PDT'.in_time_zone },
        #   { start: '2017-08-15 12:00:00PM PDT'.in_time_zone, end: '2017-08-17 12:00:00PM PDT'.in_time_zone },
        #   { start: '2017-08-17 12:00:00PM PDT'.in_time_zone, end: '2017-09-01 12:00:00PM PDT'.in_time_zone },
        #   { start: '2017-09-02 12:00:00PM PDT'.in_time_zone, end: '2017-09-15 12:00:00PM PDT'.in_time_zone }
        # ]

        # dates.each do |date|
        #   contract_datetime = @contract.created_at.in_time_zone
        #   if contract_datetime >= date[:start] && contract_datetime < date[:end]
        #     @date = date
        #     break
        #   end
        # end

        render 'token_purchase', layout: 'purchase_agreement'
      end
    end
  end
end
