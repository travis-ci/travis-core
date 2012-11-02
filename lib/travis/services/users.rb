module Travis
  module Services
    module Users
      autoload :FindAccounts,    'travis/services/users/find_accounts'
      autoload :FindBroadcasts,  'travis/services/users/find_broadcasts'
      autoload :FindByGithub,    'travis/services/users/find_by_github'
      autoload :FindPermissions, 'travis/services/users/find_permissions'
      autoload :Sync,            'travis/services/users/sync'
      autoload :Update,          'travis/services/users/update'
    end
  end
end
