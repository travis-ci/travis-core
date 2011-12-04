module Travis
  module Notifications
    module Handler
      class Pusher
        class Payload
          attr_reader :event, :object, :extra

          def initialize(event, object, extra = {})
            @event, @object, @extra = event, object, extra
          end

          def to_hash
            render(:hash)
          end

          def render(format)
            Travis::Renderer.send(format, data, :type => 'pusher', :template => template, :base_dir => base_dir).deep_merge(extra)
          end

          def data
            case object
            when ::Worker
              { :worker => object }
            else
              { :build => object, :repository => object.repository }
            end
          end

          def template
            case object
            when ::Worker
              event.to_s.split(':').first
            else
              event.to_s.split(':').join('/')
            end
          end

          def base_dir
            File.expand_path('../../../../views', __FILE__)
          end

          def to_hash
            render(:hash)
          end
        end
      end
    end
  end
end
