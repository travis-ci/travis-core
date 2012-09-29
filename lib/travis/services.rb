module Travis
  module Services
    autoload :Base,         'travis/services/base'
    autoload :Account,      'travis/services/account'
    autoload :Artifacts,    'travis/services/artifacts'
    autoload :Builds,       'travis/services/builds'
    autoload :Branches,     'travis/services/branches'
    autoload :Hooks,        'travis/services/hooks'
    autoload :Jobs,         'travis/services/jobs'
    autoload :Repositories, 'travis/services/repositories'
    autoload :Stats,        'travis/services/stats'
    autoload :Workers,      'travis/services/workers'
    autoload :User,         'travis/services/user'

    class << self
      attr_writer :namespace

      def namespace
        @namespace ||= name
      end
    end

    def all(params)
      name = case true
        when params.empty?     then :all
        when params.key?(:ids) then :by_ids
      end
      service(name, params)
    end

    def one(params)
      service(:one, params)
    end

    def one_or_create(params)
      service(:one_or_create, params)
    end

    def update(params)
      service(:update, params)
    end

    def service(type, name, params = nil)
      type, name, params = self.class.name.split('::').last, type, name if name.is_a?(Hash)
      const(type, name).new(respond_to?(:current_user) ? current_user : nil, params.symbolize_keys)
    end

    private

      def const(type, name)
        name = [Travis::Services.namespace, type, name]
        name = name.map(&:to_s).map(&:camelize).join('::')
        name.constantize
      end
  end
end
