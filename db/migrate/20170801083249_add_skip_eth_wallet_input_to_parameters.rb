class AddSkipEthWalletInputToParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      name: 'system.skip_eth_wallet_input',
      value: '0',
      description: 'Пропустить ввод ETH кошелька (пропустить=1 \ не пропускать=0)'
    )
  end
end
