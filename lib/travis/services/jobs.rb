module Travis
  module Services
    class Jobs < Base
      def find_all(params = {})
        scope(:job).queued(params[:queue]).includes(:commit)
      end

      def find_one(params)
        scope(:job).find(params[:id])
      end
    end
  end
end
