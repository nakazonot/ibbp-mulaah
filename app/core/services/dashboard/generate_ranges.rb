class Services::Dashboard::GenerateRanges
  def initialize
  end

  def call
    generate
  end

  private

  def generate
    {
      'Today': [
        Date.current.strftime('%F'),
        Date.current.strftime('%F')
      ],
      'This Week': [
        Date.current.at_beginning_of_week.strftime('%F'),
        Date.current.strftime('%F')
      ],
      'Last week': [
        1.week.ago.strftime('%F'),
        Date.current.strftime('%F')
      ],
      'This Month': [
        Date.current.beginning_of_month.strftime('%F'),
        Date.current.strftime('%F')
      ],
      'Last Month': [
        1.month.ago.strftime('%F'),
        Date.current.strftime('%F')
      ]
    }
  end
end
