module Travis
  module Api
    autoload :Formats, 'travis/api/formats'
    autoload :V0,      'travis/api/v0'
    autoload :V1,      'travis/api/v1'
    autoload :V2,      'travis/api/v2'

    class << self
      def data(resource, options = {})
        builder(resource, options).new(resource, options[:params] || {}).data
      end

      private

        def builder(resource, options = {})
          target  = (options[:for] || 'http').to_s.camelize
          version = (options[:version] || 'v1').to_s.camelize
          type    = (options[:type] || type_for(resource)).to_s.camelize
          "#{name}::#{version}::#{target}::#{type}".constantize
        end

        def type_for(resource)
          type = resource.respond_to?(:klass) ? resource.klass.name.pluralize : resource.class.base_class.name
          type = type.to_s.split('::').last
        end
    end
  end
end
