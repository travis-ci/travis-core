module Travis
  module Api
    module Http
      autoload :V1, 'travis/api/http/v1'

      class << self
        def data(type, resource, params = {}, options = {})
          builder(type).new(resource, params).data
        end

        def builder(type, options = {})
          version = options[:version] || 'v1'
          "#{name}::#{version.camelize}::#{type}".constantize
        end
      end
    end
  end
end
