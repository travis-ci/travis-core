module Travis
  module Services
    module Jobs
      class All < Base
        def run
          scope(:job).queued(params[:queue]).includes(:commit)
        end
      end
    end
  end
end
