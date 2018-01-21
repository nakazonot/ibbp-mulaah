# frozen_string_literal: true
class KycStatusType
  APPROVED    = 'approved'
  IN_PROGRESS = 'in_progress'
  REJECTED    = 'rejected'
  DRAFT       = 'draft'

  def self.all
    {
      APPROVED    => 'Approved',
      IN_PROGRESS => 'In Progress',
      REJECTED    => 'Rejected',
      DRAFT       => 'Draft'
    }
  end

  def self.description(name)
    self.all[name]
  end
end
