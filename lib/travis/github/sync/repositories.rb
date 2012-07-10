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
          fetch.map do |data|
            Repository.new(user, data).run
          end
        end
        instrument :run

        private

          def fetch
            Travis::Github.repositories_for(user)
          end
          instrument :fetch, :level => :debug

        Travis::Notification::Instrument::Github::Sync::Repositories.attach_to(self)
      end
    end
  end
end
