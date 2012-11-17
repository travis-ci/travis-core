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

      def updated_at
        result.maximum(:updated_at)
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
            params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
          else
            scope(:build).none
          end
        end

        def preload(builds)
          builds = builds.includes(:commit)
          # TODO rescue MissingAttribute in simple_states so we can stop loading :state
          ActiveRecord::Associations::Preloader.new(builds, :request, :select => [:id, :event_type, :state]).run
          ActiveRecord::Associations::Preloader.new(builds, :matrix, :select => [:id, :source_id, :state]).run
          builds
        end

        def repo
          @repo ||= Travis.run_service(:find_repository, params)
        end
    end
  end
end
