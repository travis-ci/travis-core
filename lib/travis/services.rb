module Travis
  module Services
    autoload :Base,          'travis/services/base'
    autoload :Artifacts,     'travis/services/artifacts'
    autoload :Builds,        'travis/services/builds'
    autoload :Branches,      'travis/services/branches'
    autoload :Events,        'travis/services/events'
    autoload :Github,        'travis/services/github'
    autoload :Organizations, 'travis/services/organizations'
    autoload :Hooks,         'travis/services/hooks'
    autoload :Jobs,          'travis/services/jobs'
    autoload :Requests,      'travis/services/requests'
    autoload :Repositories,  'travis/services/repositories'
    autoload :Stats,         'travis/services/stats'
    autoload :Workers,       'travis/services/workers'
    autoload :Users,         'travis/services/users'

    extend self

    def run(type, name, *args)
      service(type, name, *args).run
    end

    def service(type, name, *args)
      params = args.last.is_a?(Hash) ? args.pop : {}
      user = args.last
      user ||= current_user if respond_to?(:current_user)
      const(type, name).new(user, params)
    end

    private

      def const(type, name)
        name = ['', Travis.services.name, type, name]
        name = name.map(&:to_s).map(&:camelize).join('::')
        name.constantize
      end
  end
end
