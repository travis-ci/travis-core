module Travis
  module Api
    module V0
      module Notification
        autoload :User,       'travis/api/v0/notification/user'
        autoload :Repository, 'travis/api/v0/notification/repository'
      end
    end
  end
end

