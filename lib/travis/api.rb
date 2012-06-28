module Travis
  module Api
    autoload :Formats, 'travis/api/formats'
    autoload :V0,      'travis/api/v0'
    autoload :V1,      'travis/api/v1'
    autoload :V2,      'travis/api/v2'

    class << self
      def data(resource, options = {})
        builder = builder(resource, options)
        raise ArgumentError, "cannot serialize #{resource.inspect}" unless builder
        builder.new(resource, options[:params] || {}).data
      end

      def builder(resource, options = {})
        target  = (options[:for] || 'http').to_s.camelize
        version = (options[:version] || 'v1').to_s.camelize
        type    = (options[:type] || type_for(resource)).to_s.camelize
        [name, version, target, type].join("::").constantize rescue nil
      end

      private

        def arel_relation?(resource)
          resource.respond_to? :klass
        end

        def type_for(resource)
          if arel_relation?(resource)
            type = resource.klass.name.pluralize
          else
            type = resource.class
            type = type.base_class if type.respond_to?(:base_class)
            type = type.name
          end
          type.split('::').last
        end
    end
  end
end
