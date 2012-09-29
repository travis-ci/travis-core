module Travis
  module Services
    module Repositories
      class All < Base
        def run
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
end
