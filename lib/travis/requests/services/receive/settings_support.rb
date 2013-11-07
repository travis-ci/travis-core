module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        module SettingsSupport
          include Travis::Services::Helpers

          delegate :build_pushes?, :build_pull_requests?, :build_pull_requests_on_synchronize?,
                   to: :repository_settings

          def repository_settings
            _repository ? _repository.settings : Repository::DefaultSettings.new
          end

          def _repository
            if defined?(@_repository)
              @_repository
            else
              @_repository = run_service(:find_repo, github_id: repository[:github_id])
            end
          end
        end
      end
    end
  end
end
