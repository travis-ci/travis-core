module Travis
  module Services
    module User
      autoload :Sync,   'travis/services/user/sync'
      autoload :Update, 'travis/services/user/update'
    end
  end
end
