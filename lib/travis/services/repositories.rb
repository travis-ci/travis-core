module Travis
  module Services
    module Repositories
      autoload :All,         'travis/services/repositories/all'
      autoload :ByIds,       'travis/services/repositories/by_ids'
      autoload :One,         'travis/services/repositories/one'
      autoload :OneOrCreate, 'travis/services/repositories/one_or_create'
    end
  end
end
