module Travis
  module Services
    class Jobs
      def find_all(params)
        Job.queued.where(:queue => params[:queue]).includes(:commit)
      end

      def find_one(params)
        Job.find(params[:id])
      end
    end
  end
end
