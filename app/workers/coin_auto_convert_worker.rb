class CoinAutoConvertWorker
  include Sidekiq::Worker

  sidekiq_options unique: :while_executing

  def perform(user_id)
    Services::Coin::AutoConverter.new(user_id).call
  end

end