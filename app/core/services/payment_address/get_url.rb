class Services::PaymentAddress::GetUrl

  def initialize(payment_address)
    @payment_address = payment_address
  end

  def call
    get_address(@payment_address.payment_address, @payment_address.currency)
  end

  private

  def get_address(address, currency)
    data = {
      'BTC'  => "https://blockchain.info/address/#{address}",
      'ETH'  => "https://etherscan.io/address/#{address}",
      'LTC'  => "https://chainz.cryptoid.info/ltc/address.dws?#{address}",
      'ETC'  => "http://gastracker.io/addr/#{address}",
      'DASH' => "https://chainz.cryptoid.info/dash/address.dws?#{address}" 
    }
    data[currency]
  end
end
