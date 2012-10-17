module Travis
  module Services
    module Users
      autoload :FindBroadcasts,  'travis/services/users/find_broadcasts'
      autoload :FindByGithub,    'travis/services/users/find_by_github'
      autoload :Sync,            'travis/services/users/sync'
      autoload :Update,          'travis/services/users/update'
      autoload :FindPermissions, 'travis/services/users/find_permissions'
    end
  end
end
