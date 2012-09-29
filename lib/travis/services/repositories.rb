module Travis
  module Services
    module Repositories
      autoload :All,   'travis/services/repositories/all'
      autoload :ByIds, 'travis/services/repositories/by_ids'
      autoload :One,   'travis/services/repositories/one'
    end
  end
end
