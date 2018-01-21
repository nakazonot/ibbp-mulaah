class Services::Coin::CalcBonus

  def initialize(amount, bonus)
    @amount = amount.to_f
    @bonus = bonus.to_f
  end

  def amount_total
    @amount * (1 + @bonus / 100)
  end

  def amount_bonus
    @amount * @bonus / 100
  end
end