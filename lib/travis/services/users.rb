module Travis
  module Services
    module Users
      autoload :ByGithub, 'travis/services/users/by_github'
      autoload :Sync,     'travis/services/users/sync'
      autoload :Update,   'travis/services/users/update'
    end
  end
end
