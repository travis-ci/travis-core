module Travis
  module Services
    autoload :Base,          'travis/services/base'
    autoload :Accounts,      'travis/services/accounts'
    autoload :Artifacts,     'travis/services/artifacts'
    autoload :Builds,        'travis/services/builds'
    autoload :Branches,      'travis/services/branches'
    autoload :Events,        'travis/services/events'
    autoload :Organizations, 'travis/services/organizations'
    autoload :Hooks,         'travis/services/hooks'
    autoload :Jobs,          'travis/services/jobs'
    autoload :Requests,      'travis/services/requests'
    autoload :Repositories,  'travis/services/repositories'
    autoload :Stats,         'travis/services/stats'
    autoload :Workers,       'travis/services/workers'
    autoload :Users,         'travis/services/users'

    def all(params)
      service(params.key?(:ids) ? :by_ids : :all, params)
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

    def service(type, name = {}, params = nil)
      type, name, params = self.class.name.split('::').last, type, name if name.is_a?(Hash)
      user = current_user if respond_to?(:current_user)
      const(type, name).new(user, params)
    end

    private

      def const(type, name)
        name = [Travis.services.name, type, name]
        name = name.map(&:to_s).map(&:camelize).join('::')
        name.constantize
      end
  end
end
