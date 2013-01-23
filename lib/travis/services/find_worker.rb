module Travis
  module Services
    class FindWorker < Base
      register :find_worker

      def run
        Worker.find(params[:id])
      end
    end
  end
end
