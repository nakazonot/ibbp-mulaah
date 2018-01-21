class AddParametersBuyTokensAgreementEnabled < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'system.buy_tokens_agreement_enabled', value: 0, description: 'Необходимость вывода договора покупки токенов перед покупкой(включить=1, выключить=0)')
  end
end
