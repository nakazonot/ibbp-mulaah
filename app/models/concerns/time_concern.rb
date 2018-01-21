module TimeConcern
  extend ActiveSupport::Concern

  def datetime_in_iso8601?(datetime)
    begin
      DateTime.iso8601(datetime.to_s)
    rescue ArgumentError
      return false
    end

    true
  end
end
