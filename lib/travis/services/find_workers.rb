module Travis
  module Services
    class FindWorkers < Base
      register :find_workers

      def run
        workers = Worker.all
        workers = workers.select { |worker| params[:ids].include?(worker.id) } if params[:ids]
        workers
      end
    end
  end
end
