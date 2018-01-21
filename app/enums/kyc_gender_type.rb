# frozen_string_literal: true
class KycGenderType
  MALE    = 'male'
  FEMALE  = 'female'

  def self.all
    {
      MALE:   'Male',
      FEMALE: 'Female',
    }
  end

  def self.description(name)
    self.all[name]
  end
end
