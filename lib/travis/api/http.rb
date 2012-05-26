module Travis
  module Api
    module Http
      autoload :V1, 'travis/api/http/v1'
      autoload :V2, 'travis/api/http/v2'

      class << self
        def data(resource, params = {}, options = {})
          builder(resource, options).new(resource, params).data
        end

        private

          def builder(resource, options = {})
            version = (options[:version] || 'v1').to_s.camelize
            type = (options[:type] || type_for(resource)).to_s.camelize
            "#{name}::#{version}::#{type}".constantize
          end

          def type_for(resource)
            type = resource.respond_to?(:klass) ? resource.klass.name.pluralize : resource.class.base_class.name
            type = type.to_s.split('::').last
          end
      end
    end
  end
end
