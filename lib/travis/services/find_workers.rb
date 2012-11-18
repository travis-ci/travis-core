module Travis
  module Services
    class FindWorkers < Base
      def run
        scope(:worker).order(:host, :name)
      end
    end
  end
end
