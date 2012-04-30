module Travis
  module Api
    module Json
      module Formats
        def format_date(date)
          date && date.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      end
    end
  end
end
