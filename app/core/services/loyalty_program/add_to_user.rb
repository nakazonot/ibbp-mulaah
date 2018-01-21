class Services::LoyaltyProgram::AddToUser
  include Concerns::Log::Logger

  def initialize(params, user, payment)
    @params  = params.deep_dup
    @user    = user
    @payment = payment
    @details = JSON.parse(@params['Details'])
  end

  def call
    return unless @payment.currency_buyer == "ETH"
    @loyalty_programs = LoyaltyProgram.enabled
    return if @loyalty_programs.blank?
    @wrapper = ApiWrappers::AnyPayCoins.new
    add_to_user_loyalty_program
  end

  private

  def decimal_amount(amount, decimals)
    amount.to_d / 10**decimals.to_i
  end

  def add_to_user_loyalty_program
    @loyalty_programs.each do |program|
      balance = @wrapper.get_contract_balance(program.contract, @details['from'])
      amountf = balance['Decimals'].to_i > 0 ? decimal_amount(balance['Balance'], balance['Decimals']) : balance['Balance'].to_i
      if amountf >= program.min_amount
        user_loyalty_program = find_or_initialize_user_loyalty_program(program)
        user_loyalty_program.update_attributes({ 
          user: @user, 
          loyalty_program: program, 
          expires_at: Time.current + program.lifetime_hour.hour, 
          payment: @payment,
          updated_at: Time.current
        })
        log_info("Add LoyaltyProgram to user: ##{@user.id}, program_id: ##{program.id}, payment_id: ##{@payment.id}, from_address: #{@details['from']}")
      end
    end
  end

  def find_or_initialize_user_loyalty_program(program)
    user_loyalty_program = LoyaltyProgramsUser.by_user(@user.id).by_loyalty_program(program.id).first
    user_loyalty_program ||= LoyaltyProgramsUser.new
  end


end