module Travis
  module Api
    module Http
      module V2
        class Builds
          include Formats

          attr_reader :builds, :options

          def initialize(builds, options = {})
            @builds = builds
            @options = options
          end

          def data
            builds.map do |build|
              Build.new(build, :include_jobs => false).data
            end
          end
        end
      end
    end
  end
end
