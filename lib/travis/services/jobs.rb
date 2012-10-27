module Travis
  module Services
    module Jobs
      autoload :Enqueue, 'travis/services/jobs/enqueue'
      autoload :FindAll, 'travis/services/jobs/find_all'
      autoload :FindOne, 'travis/services/jobs/find_one'
    end
  end
end
