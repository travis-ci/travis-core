module Travis
  module Api
    module V0
      module Event
        autoload :Build, 'travis/api/v0/event/build'
        autoload :Test,  'travis/api/v0/event/test'
      end
    end
  end
end


