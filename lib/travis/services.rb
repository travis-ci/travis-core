module Travis
  module Services
    autoload :Base,         'travis/services/base'
    autoload :Builds,       'travis/services/builds'
    autoload :Jobs,         'travis/services/jobs'
    autoload :Repositories, 'travis/services/repositories'

    def service(key)
      Travis.services[key].new || raise("no service registered for #{key}")
    end
  end
end

