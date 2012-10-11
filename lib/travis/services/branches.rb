require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      autoload :FindAll, 'travis/services/branches/find_all'
    end
  end
end
