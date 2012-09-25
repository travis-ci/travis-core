module Travis
  module Services
    autoload :Builds,       'travis/services/builds'
    autoload :Jobs,         'travis/services/jobs'
    autoload :Repositories, 'travis/services/repositories'

    def service(key)
      const = Travis.services[key] || raise("no service registered for #{key}")
      const.new
    end
  end
end

