module Travis
  module Services
    autoload :Base,         'travis/services/base'
    autoload :Artifacts,    'travis/services/artifacts'
    autoload :Builds,       'travis/services/builds'
    autoload :Branches,     'travis/services/branches'
    autoload :Hooks,        'travis/services/hooks'
    autoload :Jobs,         'travis/services/jobs'
    autoload :Repositories, 'travis/services/repositories'
    autoload :Stats,        'travis/services/stats'
    autoload :Workers,      'travis/services/workers'

    def service(key)
      const = Travis.services[key] || raise("no service registered for #{key}")
      const.new(current_user)
    end
  end
end
