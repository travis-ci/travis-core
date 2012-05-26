module Travis
  module Api
    module Webhook
      class Build
        autoload :Finished, 'travis/api/webhook/build/finished'

        attr_reader :build, :commit, :request, :repository

        def initialize(build)
          @build = build
          @commit = build.commit
          @request = build.request
          @repository = build.repository
        end
      end
    end
  end
end
