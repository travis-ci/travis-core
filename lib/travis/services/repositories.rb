module Travis
  module Services
    class Repositories < Base
      def find_all(params = {})
        scope = self.scope(:repository).timeline.recent
        scope = scope.by_member(params[:member])         if params[:member]
        scope = scope.by_owner_name(params[:owner_name]) if params[:owner_name]
        scope = scope.by_slug(params[:slug])             if params[:slug]
        scope = scope.search(params[:search])            if params[:search].present?
        scope
      end

      def find_one(params)
        repository(params) || raise(ActiveRecord::RecordNotFound)
      end

      def find_or_create_by(params)
        repository(params) || scope(:repository).create!(params.slice(:owner_name, :name))
      end

      private

        def repository(params)
          scope(:repository).find_by(params)
        end
    end
  end
end
