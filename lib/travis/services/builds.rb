module Travis
  module Services
    module Builds
      autoload :All,   'travis/services/builds/all'
      autoload :ByIds, 'travis/services/builds/by_ids'
      autoload :One,   'travis/services/builds/one'
    end
  end
end
