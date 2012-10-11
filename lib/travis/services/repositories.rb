module Travis
  module Services
    module Repositories
      autoload :FindAll,      'travis/services/repositories/find_all'
      autoload :FindByGithub, 'travis/services/repositories/find_by_github'
      autoload :FindOne,      'travis/services/repositories/find_one'
    end
  end
end
