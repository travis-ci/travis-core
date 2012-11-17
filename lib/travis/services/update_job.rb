require 'travis/services/base'
require 'active_support/core_ext/hash/except'

module Travis
  module Services
    class UpdateJob < Base
      register :update_job

      def run
        job.update_attributes(attrs) # TODO really should be update_attributes!
      end

      private

        def job
          Job::Test.find(id)
        end

        def id
          params[:data][:id]
        end

        def attrs
          params[:data].except(:id)
        end
    end
  end
end

