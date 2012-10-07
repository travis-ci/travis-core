require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class One < Base
        def run
          build = scope(:build).includes(:commit, :request, :matrix).find_by_id(params[:id])
          ActiveRecord::Associations::Preloader.new(build.matrix, :log, :select => [:id, :job_id]).run if build
          build
        end
      end
    end
  end
end
