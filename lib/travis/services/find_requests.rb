require 'core_ext/active_record/none_scope'

module Travis
  module Services
    class FindRequests < Base
      register :find_requests

      def run
        result
      end

      private

        def result
          if repo
            requests = repo.requests
            if params[:older_than]
              requests.older_than(params[:older_than])
            else
              requests.recent(requests_limit)
            end
          else
            raise Travis::RepositoryNotFoundError.new
          end
        end

        def repo
          @repo ||= run_service(:find_repo, params)
        end

        def requests_limit
          max_limit = Travis.config.services.find_requests.max_limit
          default_limit = Travis.config.services.find_requests.default_limit
          if !params[:limit]
            default_limit
          elsif params[:limit] > max_limit
            max_limit
          else
            params[:limit]
          end
        end
    end
  end
end
