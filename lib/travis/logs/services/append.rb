require 'travis/services/base'

module Travis
  class Logs
    module Services
      class Append < Travis::Services::Base
        register :append_log

        def run
          job.append_log!(data[:log])
        end

        private

          def job
            Job::Test.find(data[:id])
          end

          def data
            @data ||= params[:data].symbolize_keys
          end
      end
    end
  end
end
