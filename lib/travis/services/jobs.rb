module Travis
  module Services
    module Jobs
      autoload :All,   'travis/services/jobs/all'
      autoload :ByIds, 'travis/services/jobs/by_ids'
      autoload :One,   'travis/services/jobs/one'
    end
  end
end
