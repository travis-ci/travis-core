module Travis
  module Services
    class FindRepos < Base
      def run
        result
      end

      def updated_at
        result.maximum(:updated_at)
      end

      private

        def result
          @result ||= params[:ids] ? by_ids : by_params
        end

        def by_ids
          scope(:repository).where(:id => params[:ids])
        end

        def by_params
          scope = self.scope(:repository).timeline.recent
          scope = scope.by_member(params[:member])         if params[:member]
          scope = scope.by_owner_name(params[:owner_name]) if params[:owner_name]
          scope = scope.by_slug(params[:slug])             if params[:slug]
          scope = scope.search(params[:search])            if params[:search].present?
          scope
        end
    end
  end
end
