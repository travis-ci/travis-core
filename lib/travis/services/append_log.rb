require 'travis/services/base'

module Travis
  module Services
    class AppendLog < Base
      register :append_log

      def run
        job.append_log!(log)
      end

      private

        def job
          Job::Test.find(id)
        end

        def id
          params[:data][:id]
        end

        def log
          params[:data][:log]
        end
    end
  end
end
