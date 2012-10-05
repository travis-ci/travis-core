require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class One < Base
        def run
          scope(:build).includes(:commit, :matrix => [:commit, :log]).find_by_id(params[:id])
        end
      end
    end
  end
end
