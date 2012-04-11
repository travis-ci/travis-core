class Job

  # Executes a configure job remotely and keeps tabs about state changes
  # throughout its lifecycle in the database.
  #
  # Job::Configure belongs to a Request and will be created with the Request.
  class Configure < Job
    autoload :States, 'travis/model/job/configure/states'

    include States
  end
end
