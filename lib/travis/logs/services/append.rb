module Travis
  module Logs
    module Services
      class Append < Travis::Services::Base
        register :logs_append

        def run
          Artifact::Log.append(job.id, chars)
          job.notify(:log, _log: chars)
        end

        private

          def job
            Job::Test.find(data[:id])
          end

          def chars
            data[:log]
          end

          def data
            @data ||= params[:data].symbolize_keys
          end
      end
    end
  end
end
