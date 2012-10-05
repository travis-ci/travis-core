module Travis
  module Services
    module Repositories
      autoload :All,      'travis/services/repositories/all'
      autoload :ByGithub, 'travis/services/repositories/by_github'
      autoload :One,      'travis/services/repositories/one'
    end
  end
end
