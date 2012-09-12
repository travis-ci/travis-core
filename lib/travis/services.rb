module Travis
  module Services
    autoload :Builds,       'travis/services/builds'
    autoload :Jobs,         'travis/services/jobs'
    autoload :Repositories, 'travis/services/repositories'

    def service(key)
      Travis.services[key] || raise("no service registered for #{key}")
    end
  end
end

