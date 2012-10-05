require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      autoload :All, 'travis/services/branches/all'
    end
  end
end
