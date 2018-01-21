class LoyaltyProgramsUser < ActiveRecord::Base
  belongs_to :loyalty_program, -> { with_deleted }
  belongs_to :user
  belongs_to :payment

  scope :by_user,            ->(u_id) { where(user_id: u_id) }
  scope :by_loyalty_program, ->(p_id) { where(loyalty_program_id: p_id) }

  def self.search_actual_loyalty_programs_by_user(user_id)
    self.by_user(user_id).includes(:loyalty_program)
      .where('loyalty_programs.deleted_at' => nil)
      .where('loyalty_programs.is_enabled' => true)
      .where('expires_at IS NULL OR expires_at > ?', Time.current)
      .order('loyalty_programs.bonus_percent DESC')
      .limit(1)
  end

  def actual?
    (expires_at.blank? || expires_at > Time.current) && self.loyalty_program.deleted_at.nil?
  end
end