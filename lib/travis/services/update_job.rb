require 'travis/services/base'
require 'active_support/core_ext/hash/except'

module Travis
  module Services
    class UpdateJob < Base
      register :update_job

      def run
        job.update_attributes(data.except(:id)) # TODO really should be update_attributes!
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

