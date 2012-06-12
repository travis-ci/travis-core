module Travis
  module Github
    module Sync
      autoload :Organizations, 'travis/github/sync/organizations'
      autoload :Repositories,  'travis/github/sync/repositories'
      autoload :Repository,    'travis/github/sync/repository'
      autoload :User,          'travis/github/sync/user'
    end
  end
end
