module Travis
  module Api
    module V0
      module Notification
        autoload :Build,      'travis/api/v0/notification/build'
        autoload :Repository, 'travis/api/v0/notification/repository'
        autoload :User,       'travis/api/v0/notification/user'
      end
    end
  end
end

