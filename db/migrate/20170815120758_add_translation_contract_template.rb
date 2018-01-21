class AddTranslationContractTemplate < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      [
        { locale: 'en', key: 'main.contract_template_html', value: '<p>%{time_now}</p><h3 class="center">MYCOMPANY<br>CROWDSALE TERMS</h3><p class="justify"> PLEASE READ THESE CROWDSALE TERMS CAREFULLY. NOTE THAT SECTION N CONTAINS A BINDING ARBITRATION CLAUSE AND CLASS ACTION WAIVER, WHICH AFFECT YOUR LEGAL RIGHTS. IF YOU DO NOT AGREE TO THESE TERMS, DO NOT PURCHASE TOKENS.</p><p>You %{name} (“Purchaser,” “You”), the user of an email address %{email}, purchase of %{coin_amount} tokens <u>("Tokens")</u> during the Crowdsale (as defined below) from MYCOMPANY (the <u>"Company," "we,"</u> or <u>"us"</u>) is subject to these terms of sale <u>("Terms")</u>. Each of you and Company is a <u>"Party"</u> and, together, the <u>"Parties."</u></p><p>You and Company agree as follows:</p><ol><li>Purchase of Tokens. The Company is selling to you and you are purchasing from the Company %{coin_amount} Tokens at the price of %{coin_rate} %{currency} per Token (“Purchase Price”) totaling %{coin_price}%{currency} (“Aggregate Amount”).</li></ol>' },
      ]
    )
  end
end
