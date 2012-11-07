module Travis
  module Services
    module Hooks
      autoload :FindAll, 'travis/services/hooks/find_all'
      autoload :FindOne, 'travis/services/hooks/find_one'
      autoload :Update,  'travis/services/hooks/update'
    end
  end
end
