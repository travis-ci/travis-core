module Travis
  module Services
    class Jobs
      def find_all(params = {})
        scope.queued.where(:queue => params[:queue]).includes(:commit)
      end

      def find_one(params)
        scope.find(params[:id])
      end

      private

        def scope
          Job
        end
    end
  end
end
