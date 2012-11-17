require 'travis/services/base'

module Travis
  module Services
    class FindWorkers < Base
      register :find_workers

      def run
        scope(:worker).order(:host, :name)
      end
    end
  end
end
