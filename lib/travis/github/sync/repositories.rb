module Travis
  module Github
    module Sync
      class Repositories
        autoload :Repository, 'travis/github/sync/repositories/repository'

        extend Travis::Instrumentation

        attr_reader :user

        def initialize(user)
          @user = user
        end

        def run
          user.authenticated_on_github do
            Travis::Github.repositories_for(user).each do |data|
              Repository.new(user, data).run
            end
          end
        end
        instrument :run

        Travis::Notification::Instrument::Github::Sync::Repositories.attach_to(self)
      end
    end
  end
end
