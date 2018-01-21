class Services::Payment::GetLink
  def call(payment)
    @payment = payment
    if @payment.transaction_id.blank? || @payment.currency_buyer.blank? || (url = get_url(@payment.transaction_id, @payment.currency_buyer)).blank?
      return @payment.amount_buyer
    end
    ActionController::Base.helpers.link_to original_number_format(@payment.amount_buyer),
      url,
      target: '_blank'
  end

  private

  def get_url(txn_id, currency)
    data = {
      'BTC'  => "https://blockchain.info/tx/#{txn_id}",
      'ETH'  => "https://etherscan.io/tx/#{txn_id}",
      'LTC'  => "https://chainz.cryptoid.info/ltc/tx.dws?#{txn_id}",
      'ETC'  => "http://gastracker.io/tx/#{txn_id}",
      'DASH' => "https://chainz.cryptoid.info/dash/tx.dws?#{txn_id}" 
    }
    data[currency]
  end
end
