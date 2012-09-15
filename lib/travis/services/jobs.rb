module Travis
  module Services
    class Jobs < Base
      def find_all(params = {})
        return find_by_ids(params) if params.key?(:ids)
        scope(:job).queued(params[:queue]).includes(:commit)
      end

      def find_by_ids(params)
        scope(:job).where(:id => params[:ids])
      end

      def find_one(params)
        scope(:job).find(params[:id])
      end
    end
  end
end
