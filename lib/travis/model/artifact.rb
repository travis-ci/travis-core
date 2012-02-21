require 'active_record'

# Models an artifact that is generated from executing a Job.
#
# The only artifact type we currently generate is the log output from a
# Job::Test. We might generate other artifacts like uploaded screenshots
# or code/test suite analysis results in future.
#
# Aggregating the log instead of storing it on the jobs table also makes
# it easier to prevent from accidentally loading it to memory which happens
# quite easily with # ActiveRecord.

class Artifact < ActiveRecord::Base
  autoload :Log, 'travis/model/artifact/log'

  belongs_to :job
end
