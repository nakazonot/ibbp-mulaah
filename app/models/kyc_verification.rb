class KycVerification < ApplicationRecord
  REJECTED_TIME_PERIOD_DAYS = 7.days.ago

  belongs_to :user, -> { with_deleted }

  scope :by_user,          ->(user_id)  { where(user_id: user_id) }
  scope :by_status,        ->(status)   { where(status: status) }
  scope :required_sync,    ->           { where('status = ? OR (sent_at >= ? AND status = ?)', KycStatusType::IN_PROGRESS, REJECTED_TIME_PERIOD_DAYS, KycStatusType::REJECTED) }

  def approved?
    self.status == KycStatusType::APPROVED
  end

  def in_progress?
    self.status == KycStatusType::IN_PROGRESS
  end

  def rejected?
    self.status == KycStatusType::REJECTED
  end

  def kyc
    {
      first_name:            self.first_name,
      middle_name:           self.middle_name,
      last_name:             self.last_name,
      document_number:       self.document_number,
      phone:                 self.phone,
      gender:                self.gender,
      address:               self.address,
      state:                 self.state,
      dob:                   self.dob,
      city:                  self.city,
      citizenship:           self.citizenship,
      country_code:          self.country_code
    }
  end

  def data_fully?
    self.kyc.each { |_key, value| return false if value.empty? }

    true
  end

  def can_send_for_verify?
    ![KycStatusType::APPROVED, KycStatusType::IN_PROGRESS].include?(self.status)
  end

  def get_user_age
    user_age = Time.current.year - self.dob.year
    if Time.current.month < self.dob.month || (Time.current.month == self.dob.month && Time.current.day < self.dob.day)
      user_age -= 1
    end
    user_age
  end

end
