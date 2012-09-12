module Travis
  module Services
    class Jobs
      def find_all(params)
        model.queued.where(:queue => params[:queue]).includes(:commit)
      end

      def find_one(params)
        model.find(params[:id])
      end

      private

        def model
          Job
        end
    end
  end
end
