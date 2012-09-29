module Travis
  module Services
    module Repositories
      class ByIds < Base
        def run
          scope(:repository).where(:id => params[:ids])
        end
      end
    end
  end
end
