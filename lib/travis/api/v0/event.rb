module Travis
  module Api
    module V0
      module Event
        autoload :Build, 'travis/api/v0/event/build'
        autoload :Job,   'travis/api/v0/event/job'
      end
    end
  end
end


