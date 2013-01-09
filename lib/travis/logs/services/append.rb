module Travis
  module Logs
    module Services
      class Append < Travis::Services::Base
        register :logs_append

        def run
          Artifact::Log.append(job.id, chars, number, final)
          job.notify(:log, _log: chars)
        end

        private

          def job
            Job::Test.find(data[:id])
          end

          def chars
            data[:log]
          end

          def number
            data[:number]
          end

          def final
            !!data[:final]
          end

          def data
            @data ||= params[:data].symbolize_keys
          end
      end
    end
  end
end
