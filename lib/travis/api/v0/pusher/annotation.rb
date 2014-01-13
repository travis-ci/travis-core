module Travis
  module Api
    module V0
      module Pusher
        class Annotation
          require 'travis/api/v0/pusher/annotation/created'
          require 'travis/api/v0/pusher/annotation/updated'

          include Formats

          def initialize(annotation, options = {})
            @annotation = annotation
          end

          def data
            {
              'annotation' => V2::Http::Annotations.new([@annotation]).data['annotations'].first,
            }
          end
        end
      end
    end
  end
end
