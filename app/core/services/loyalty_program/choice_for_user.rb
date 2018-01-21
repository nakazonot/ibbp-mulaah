class Services::LoyaltyProgram::ChoiceForUser
  def initialize(user)
    @user = user
  end

  def call
    LoyaltyProgramsUser.search_actual_loyalty_programs_by_user(@user.id).first
  end
end