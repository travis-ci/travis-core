module Travis
  module Services
    module Users
      autoload :Sync,   'travis/services/users/sync'
      autoload :Update, 'travis/services/users/update'
    end
  end
end
