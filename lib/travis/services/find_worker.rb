module Travis
  module Services
    class FindWorker < Base
      register :find_worker

      def run
        scope(:worker).find_by_id(params[:id])
      end
    end
  end
end
