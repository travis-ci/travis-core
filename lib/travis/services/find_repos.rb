require 'travis/services/base'

module Travis
  module Services
    class FindRepos < Base
      register :find_repos

      def run
        result
      end

      private

        def result
          @result ||= params[:ids] ? by_ids : by_params
        end

        def by_ids
          scope(:repository).where(:id => params[:ids])
        end

        def by_params
          scope = self.scope(:repository).without_invalidated
          scope = scope.timeline.recent                    if timeline?
          scope = scope.by_member(params[:member])         if params[:member]
          scope = scope.by_owner_name(params[:owner_name]) if params[:owner_name]
          scope = scope.by_slug(params[:slug])             if params[:slug]
          if params[:search].present?
            scope = scope.search(params[:search]).order('last_build_started_at DESC NULLS LAST').limit(25)
          end
          scope
        end

        def timeline?
          # :member is passed for the left sidebar on pro/enterprise
          not [:owner_name, :slug, :search].any? { |key| params[key] }
        end
    end
  end
end
