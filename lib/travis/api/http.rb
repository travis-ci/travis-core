module Travis
  module Api
    module Http
      autoload :V1, 'travis/api/http/v1'
      autoload :V2, 'travis/api/http/v2'

      class << self
        def data(type, resource, params = {}, options = {})
          builder(type, options).new(resource, params).data
        end

        def builder(type, options = {})
          type = type.to_s.split('::').last.camelize
          version = (options[:version] || 'v1').camelize
          "#{name}::#{version}::#{type}".constantize.tap { |c| p c }
        end
      end
    end
  end
end
