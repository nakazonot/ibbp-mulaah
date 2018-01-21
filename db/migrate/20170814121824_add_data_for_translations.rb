class AddDataForTranslations < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      [
        { locale: 'en', key: 'main.distribution_h', value: 'Distribution, initial rate, and token exchange' },
        { locale: 'en', key: 'main.distribution_html', value: "<table class=\"table info-block\"><tr><td><h4>Initial MYTOKEN token rate</h4></td><td><p class=\"table-price”>0.008 - 0.012 BTC</p><p>Depending on the time of purchase.</p><p>Time is set in Pacific Daylight zone.</p></td></tr><tr><td><h4>Presale: Early Bird</h4><p>August 15, 2017 9:00 AM - 9:00 PM</p></td><td><p class=\"table-price\">0.008 BTC</p><p>Min purchase - 10,000 MYTOKEN tokens (80 BTC)</p></td></tr><tr><td><h4>Presale</h4><p>August 15, 2017, 9:00 PM -</p><p>August 20, 2017, 12:00 PM</p></td><td><p class=\"table-price\">0.009 BTC</p><p>Min purchase - 1,000 MYTOKEN tokens (9 BTC)</p> </td></tr><tr><td><h4>ICO: Early Bird</h4><p>August 20, 2017, 12:00 PM - </p><p>August 22, 2017, 12:00 PM</p></td><td><p class=\"table-price\">0.01 BTC</p><p>Min purchase - 1 MYTOKEN token (0.01 BTC)</p></td></tr><tr><td><h4>ICO 1st</h4><p>August 22, 2017, 12:00 PM -</p><p>September 5, 2017, 12:00 PM</p></td><td><p class=\"table-price\">0.011 BTC</p><p>Min purchase - 1 MYTOKEN token (0.011 BTC)</p></td></tr><tr><td><h4>ICO 2nd</h4><p>September 5, 2017, 12:00 PM - </p><p>September 20, 2017, 12:00 PM</p></td><td><p class=\"table-price\">0.012 BTC</p><p>Min purchase - 1 MYTOKEN token (0.012 BTC)</p></td></tr></table>" },
        { locale: 'en', key: 'main.info_block.description_html', value: '<p>Thank you for your interest in purchasing the MYTOKEN tokens.</p><p>You can purchase MYTOKEN tokens at the following rates:</p>' },
        { locale: 'en', key: 'main.info_block.description_show_ico_html', value: '<p>Here you will be able to deposit funds and purchase MYTOKEN Tokens.</p>' },
        { locale: 'en', key: 'main.step.calc_block.description_html', value: '<p>You can buy MYTOKEN tokens using BTC, ETH, LTC, DASH, ZEC, or USD.</p><p>The calculator is provided for your convenience. You can enter a number of MYTOKEN tokens you want to buy and calculate the amount you would need to have in your account wallets.</p><p>If you want to purchase MYTOKEN tokens with any currency other than BTC, please note that the price of the tokens will be calculated at the time of the actual token purchase and not at the time of the funds deposit.</p>' },
        { locale: 'en', key: 'main.step.calc_block.h', value: 'Plan your MYTOKEN tokens purchase' },
        { locale: 'en', key: 'main.step.login.description_html', value: 'Please log in or register to buy MYTOKEN tokens. For your convenience, there is no confirmation letter. If you have any problems, please contact %{mail}' },
        { locale: 'en', key: 'main.step.login.h', value: 'Log in or Register.' },
        { locale: 'en', key: 'main.step.make_deposit.crypt_description_html', value: '<p>The funds will appear in your account wallets only after your cryptocurrency transaction gets 6 confirmations. You will receive an email about the successful deposit.</p>' },
        { locale: 'en', key: 'main.step.make_deposit.h', value: 'Make a deposit' },
        { locale: 'en', key: 'main.step.make_deposit.usd_description_html', value: '<p>How it works:</p> <ol> <li>Generate the invoice for the sum you want to deposit (minimum allowed amount for wire transfer is $%{min_amount_for_transfer}).</li> <li>Find the invoice sent to your email address, download and pay it.</li> <li>The funds will appear in your account as soon as the payment is confirmed. You will receive an email about the successful deposit.</li> </ol>' },
        { locale: 'en', key: 'main.step.receipt_address.h', value: 'Check your token receipt address' },
        { locale: 'en', key: 'main.step.receipt_address.warning', value: 'Attention: your wallet must support ERC-20.' },
        { locale: 'en', key: 'main.step.referral_link_html', value: '<p>This is your MYTOKEN referral link. You can use it to share the project with your friends and other interested parties. If any of them sign up with this link, they will be added to your referral program. Your reward amounts to %{percent}% of all MYTOKEN tokens purchased by your referrals.</p>' },
        { locale: 'en', key: 'main.welcome.h', value: 'Welcome' },
        { locale: 'en', key: 'main.welcome.sign_in_h', value: 'Welcome to your account!' },
      ]
    )
  end
end
