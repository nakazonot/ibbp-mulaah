namespace :dev_test do
  desc 'Test ipn transaction'
  task coin_payment_transaction: :environment do
    p transaction = ApiWrappers::CoinPayments.new.create_transaction({
      amount: 0.0001,
      currency_original: 'ETH',
      currency_buyer: 'ETH',
      custom: {coin_amount_origin: 120.5, coin_bonus: 0.2, coin_amount: 140.5, user_id: 1}
    })
  end

  task coin_payment_rate: :environment do
    # p Coinpayments.rates(accepted: 1).delete_if { |_k, v| v["accepted"] == 0 }
    p Coinpayments.rates.USD.rate_btc
    # p Coinpayments.rates
  end

  task test_notification: :environment do
    merchant_id = ENV['COIN_PAYMENTS_MERCHANT_ID']
    secret = ENV['COIN_PAYMENTS_IPN_SECRET']
    p hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), secret, 'request.raw_post0000')
  end

  task get_callback_address: :environment do
    p ApiWrappers::CoinPayments.new.get_callback_address('ETH')
  end

  task invoiced_customer: :environment do
    require "invoiced"
    invoiced = Invoiced::Client.new("dXlixlHh3N3pJsl1nwp5X74BFmEOP29i", true)

    p customer = invoiced.Customer.create(
      :name => "Jane",
      :email => "6xyu@mail.ru",
      # :number => "1234",
      :payment_terms => "NET 30"
    )
  end

  task invoiced_create: :environment do
    require "invoiced"
    invoiced = Invoiced::Client.new("dXlixlHh3N3pJsl1nwp5X74BFmEOP29i", true)

    p invoice = invoiced.Invoice.create(
      :customer => 80500,
      :items => [
        {
          :name => "Balance replenishment",
          :quantity => 1,
          :unit_cost => 10
        }
      ],
      :taxes => [
        {
          :amount => 0
        }
      ]
    )
  end

  task any_pay_coins_adresses: :environment do
    p ApiWrappers::AnyPayCoins.new.get_adresses('eth', 1)
  end
  task any_pay_coins_addresses_list: :environment do
    p ApiWrappers::AnyPayCoins.new.get_addresses_list
  end

  task any_pay_coins_notification: :environment do
    params = '{"Address":"0xf1c2fece24c6a2e78a6782bbd0821a9adc927204","Amount":"10000000","Args":"{}","ClientId":"7","Confirmations":"1","Contract":"0xCFA66eebF415bAfAF725CC65011ae9dFD7B51CFA","Currency":"eth","Decimals":"6","Details":"{\"r\": \"0x8e7c1aee025bfa7ed91374cb234ac4234c5432bdb880c51ee3510a464c7941e4\", \"s\": \"0x530845328b15a4a7fd732fc0b85f68d791c5e9c42a5735e451797d42a524d488\", \"v\": \"0x25\", \"to\": \"0xcfa66eebf415bafaf725cc65011ae9dfd7b51cfa\", \"gas\": \"0xcc61\", \"from\": \"0x5130580a2be33b33d69db0cc40340634d64492fe\", \"hash\": \"0x8fa200052c3c8d53de9699587965c4a5c53b05bc1b48e641091edbf38fbb3a30\", \"input\": \"0xa9059cbb000000000000000000000000f1c2fece24c6a2e78a6782bbd0821a9adc9272040000000000000000000000000000000000000000000000000000000000989680\", \"nonce\": \"0x4\", \"value\": \"0x0\", \"gasPrice\": \"0x28fa6ae00\", \"blockHash\": \"0x955a9435427a890a97fe5a857fc8615a4e94e7aed73e65dbe92f7b757767921d\", \"blockNumber\": \"0x446928\", \"transactionIndex\": \"0xb9\"}","Hash":"kzgAmKj4uOehb9V5kHFzl4H2MS0=","Receipt":"{\"to\": \"0xcfa66eebf415bafaf725cc65011ae9dfd7b51cfa\", \"from\": \"0x5130580a2be33b33d69db0cc40340634d64492fe\", \"logs\": [{\"data\": \"0x0000000000000000000000000000000000000000000000000000000000989680\", \"topics\": [\"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef\", \"0x0000000000000000000000005130580a2be33b33d69db0cc40340634d64492fe\", \"0x000000000000000000000000f1c2fece24c6a2e78a6782bbd0821a9adc927204\"], \"address\": \"0xcfa66eebf415bafaf725cc65011ae9dfd7b51cfa\", \"removed\": false, \"logIndex\": \"0x46\", \"blockHash\": \"0x955a9435427a890a97fe5a857fc8615a4e94e7aed73e65dbe92f7b757767921d\", \"blockNumber\": \"0x446928\", \"transactionHash\": \"0x8fa200052c3c8d53de9699587965c4a5c53b05bc1b48e641091edbf38fbb3a30\", \"transactionIndex\": \"0xb9\"}], \"status\": \"0x1\", \"gasUsed\": \"0xcc61\", \"blockHash\": \"0x955a9435427a890a97fe5a857fc8615a4e94e7aed73e65dbe92f7b757767921d\", \"logsBloom\": \"0x00000000000000000000040000000000000000000000000000000002000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000010000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000002000000000000000000000000000000000000000000000100000000000004000000000000000000000000000000000000000000000000001000000000\", \"blockNumber\": \"0x446928\", \"contractAddress\": null, \"transactionHash\": \"0x8fa200052c3c8d53de9699587965c4a5c53b05bc1b48e641091edbf38fbb3a30\", \"transactionIndex\": \"0xb9\", \"cumulativeGasUsed\": \"0x6401e9\"}","Status":"pending","Txid":"0x8fa200052c3c8d53de9699587965c4a5c53b05bc1b48e641091edbf38fbb3a30","Type":"receive","controller":"anypaycoins_notifications","action":"create"}'
    p params = JSON.parse(params)

    data = {
      'Address':        params['Address'],
      'Amount':         params['Amount'],
      'Args':           params['Args'],
      'ClientId':       params['ClientId'],
      'Confirmations':  params['Confirmations'],
      'Contract':       params['Contract'],
      'Currency':       params['Currency'],
      'Decimals':       params['Decimals'],
      'Details':        params['Details'],
      'Receipt':        params['Receipt'],
      'Status':         params['Status'],
      'Txid':           params['Txid'],
      'Type':           params['Type'],
    }

    secret = 'gssBI7vfG8ZSeOmOd7yi'
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, data.to_query)
    p enc   = [[hmac].pack("H*")].pack("m0")
    p params['Hash']
    puts "Result"
    p enc == params['Hash']

    # p Services::PaymentSystem::AnyPayCoinsCreator.new(params).call
  end
  
  task any_pay_coins_sync: :environment do
    p ApiWrappers::AnyPayCoins.new.get_available_currencies
    # p Services::PaymentSystem::MainWrapper.new.get_rates
    # Services::PaymentAddress::FreePaymentAddressGenerator.new(nil, 1).call
  end

  task contract_balance: :environment do
    ai = '0xCFA66eebF415bAfAF725CC65011ae9dFD7B51CFA' #contract
    ax = '0xf1c2fece24c6a2e78a6782bbd0821a9adc927204'
    p ApiWrappers::AnyPayCoins.new.get_contract_balance(ai, ax)
  end

  task contract_transfer: :environment do
    ai = '0xCFA66eebF415bAfAF725CC65011ae9dFD7B51CFA' #contract
    ax = '0xf1c2fece24c6a2e78a6782bbd0821a9adc927204'
    p ApiWrappers::AnyPayCoins.new.contract_transfer(ai, ax, 10000000)
  end

  task test: :environment do
    # p ApiWrappers::IcosId.new.get_account_by_email('6xyu@mail.ru')
    # params = {
    #   email: 'janelevina@gmail.com',
    #   first_name: 'Jane',
    #   middle_name: '',
    #   last_name: 'Levina',
    # }
    # p ApiWrappers::IcosId.new.create_account_by_email(params)

    params = {
      email: 'janelevina@gmail.com',
      # callback_url: 'https://tokensale.bbdemo.tech/anypaycoins_notifications',
      first_name: 'Jane',
      middle_name: '',
      last_name: 'Levina',
      gender: 'female',
      phone: '79787911605',
      citizenship: 'RU',
      country_code: 'RU',
      state: 'Sevastopol',
      city: 'Sevastopol',
      address: 'Shevchenko 20',
      documents: {'back' => File.new('/var/www/ibbp/tmp/img.jpg'), 'front' => File.new('/var/www/ibbp/tmp/img.jpg'),
        'proof' => File.new('/var/www/ibbp/tmp/img.jpg'),'selfie' => File.new('/var/www/ibbp/tmp/img.jpg')},
    }
    p ApiWrappers::IcosId.new.kyc_verify(params)
  end

end

