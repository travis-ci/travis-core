require 'core_ext/active_record/none_scope'
require 'travis/services/base'

# v2 builds.all
#   build => commit, request, matrix.id

module Travis
  module Services
    class FindBuilds < Base
      register :find_builds

      def run
        preload(result)
      end

      private

        def result
          @result ||= params[:ids] ? by_ids : by_params
        end

        def by_ids
          scope(:build).where(:id => params[:ids])
        end

        def by_params
          if repo
            # TODO :after_number seems like a bizarre api why not just pass an id? pagination style?
            builds = repo.builds
            builds = builds.by_event_type(params[:event_type]) if params[:event_type]
            if params[:number]
              builds.where(:number => params[:number].to_s)
            else
              builds.older_than(params[:after_number])
            end
          elsif params.nil? || params == {}
            scope(:build).order('id DESC').where(state: ['failed', 'passed']).limit(25)
          else
            scope(:build).none
          end
        end

        def preload(builds)
          builds.includes(:commit)
        end

        def repo
          @repo ||= run_service(:find_repo, params)
        end
    end
  end
end
