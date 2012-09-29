module Travis
  module Services
    module Hooks
      autoload :All,    'travis/services/hooks/all'
      autoload :One,    'travis/services/hooks/one'
      autoload :Update, 'travis/services/hooks/update'
    end
  end
end
