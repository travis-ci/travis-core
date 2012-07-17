module Travis
  module Api
    module V1
      module Webhook
        class Build
          autoload :Finished, 'travis/api/v1/webhook/build/finished'

          attr_reader :build, :commit, :request, :repository

          def initialize(build, options = {})
            @build = build
            @commit = build.commit
            @request = build.request
            @repository = build.repository
          end

          private

          def build_url
            [Travis.config.http_host, repository.slug, 'builds', build.id].join('/')
          end
        end
      end
    end
  end
end
