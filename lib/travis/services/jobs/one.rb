module Travis
  module Services
    module Jobs
      class One < Base
        def run
          scope(:job).find_by_id(params[:id])
        end
      end
    end
  end
end
