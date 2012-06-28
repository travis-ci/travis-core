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
        type    = (options[:type] || type_for(resource)).to_s.camelize.split('::')
        [version, target, *type].inject(self) do |base, const|
          base.const_get(const) if base and base.const_defined? const, false
        end
      end

      private

        def type_for(resource)
          type = resource.class
          type = type.klass      if type.respond_to? :klass
          type = type.base_class if type.respond_to? :base_class
          type.name.split('::').last
        end
    end
  end
end
