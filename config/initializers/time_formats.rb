Time::DATE_FORMATS[:api_datetime] = lambda { |datetime| datetime.iso8601(4) }
Time::DATE_FORMATS[:api_date]     = lambda { |date| date.strftime("%Y-%m-%d") }