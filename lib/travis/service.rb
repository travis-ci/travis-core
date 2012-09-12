module Travis
  class Service
    autoload :Builds,       'travis/service/builds'
    autoload :Jobs,         'travis/service/jobs'
    autoload :Repositories, 'travis/service/repositories'

    attr_reader :services

    def initialize(services = {})
      @services = services
    end

    def service(key)
      services[key] || raise("no service registered for #{key}")
    end
  end
end

