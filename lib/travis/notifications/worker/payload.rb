module Travis
  module Notifications
    class Worker
      class Payload < Notifications::Payload
        class << self
          def for(job)
            new(job).to_hash
          end
        end

        attr_reader :job

        def initialize(job)
          @job = job
        end

        def render(format)
          Travis::Renderer.send(format, data, :type => 'worker', :template => template, :base_dir => base_dir).deep_merge(:queue => job.queue)
        end

        def data
          { :job => job, :repository => job.repository }
        end

        def template
          job.class.name.underscore
        end

        def base_dir
          File.expand_path('../../../views', __FILE__)
        end
      end
    end
  end
end
