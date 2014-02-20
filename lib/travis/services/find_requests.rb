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
              requests.recent
            end
          else
            raise Travis::RepositoryNotFoundError.new
          end
        end

        def repo
          @repo ||= run_service(:find_repo, params)
        end
    end
  end
end
