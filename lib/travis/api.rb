module Travis
  module Api
    autoload :Formats, 'travis/api/formats'
    autoload :V0,      'travis/api/v0'
    autoload :V1,      'travis/api/v1'
    autoload :V2,      'travis/api/v2'

    DEFAULT_VERSION = 'v2'

    class << self
      def data(resource, options = {})
        new(resource, options).data
      end

      def builder(resource, options = {})
        target  = (options[:for] || 'http').to_s.camelize
        version = (options[:version] || DEFAULT_VERSION).to_s.camelize
        type    = (options[:type] || type_for(resource)).to_s.camelize
        [name, version, target, type].join('::').constantize rescue nil
      end

      def new(resource, options = {})
        builder = builder(resource, options) || raise(ArgumentError, "cannot serialize #{resource.inspect}")
        builder.new(resource, options[:params] || {})
      end

      private

        def type_for(resource)
          if arel_relation?(resource)
            type = resource.klass.name.pluralize
          else
            type = resource.class
            type = type.base_class if active_record?(type)
            type = type.name
          end
          type.split('::').last
        end

        def arel_relation?(object)
          object.respond_to?(:klass)
        end

        def active_record?(object)
          object.respond_to?(:base_class)
        end
    end
  end
end
