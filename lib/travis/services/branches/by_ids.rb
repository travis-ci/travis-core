require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      class ByIds < Base
        def run
          scope(:build).where(:id => params[:ids])
        end
      end
    end
  end
end
