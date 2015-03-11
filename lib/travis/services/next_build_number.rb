require 'travis/services/base'

module Travis
  module Services
    class NextBuildNumber < Base
      extend Travis::Instrumentation

      register :next_build_number

      def initialize(*)
        super
      end

      def run
      end
      instrument :run

    end
  end
end
