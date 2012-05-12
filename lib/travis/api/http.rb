module Travis
  module Api
    module Http
      autoload :V1, 'travis/api/http/v1'
      autoload :V2, 'travis/api/http/v2'

      class << self
        def data(type, resource, params = {}, options = {})
          builder(type).new(resource, params).data
        end

        def builder(type, options = {})
          type = type.to_s.camelize
          version = (options[:version] || 'v1').camelize
          "#{name}::#{version}::#{type}".constantize
        end
      end
    end
  end
end
