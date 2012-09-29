module Travis
  module Services
    module Jobs
      class One < Base
        def run
          scope(:job).find(params[:id])
        end
      end
    end
  end
end
