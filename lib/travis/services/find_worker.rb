module Travis
  module Services
    class FindWorker < Base
      def run
        scope(:worker).find_by_id(params[:id])
      end
    end
  end
end
