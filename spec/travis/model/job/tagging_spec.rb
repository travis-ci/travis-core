require 'spec_helper'

describe Job::Tagging do
  include Support::ActiveRecord

  let(:rules) do
    YAML.load <<-yml
    - tag: rake_not_bundled
      pattern: rake is not part of the bundle
      message: Your Gemfile is missing Rake.
    - tag: database_missing
      pattern: database "[^"]*" does not exist
      message: Your test database is missing
    - tag: log_limit_exceeded
      message: Your test suite has output more than 4194304 Bytes
      pattern: The log length has exceeded the limit
    yml
  end

  let(:log) do
    <<-log
      in `block in replace_gem': rake is not part of the bundle. Add it to Gemfile. (Gem::LoadError)
      PGError: FATAL:  database "data_migrations_test" does not exist
    log
  end

  let(:job) { Factory(:test) }

  before :each do
    Job::Tagging.stubs(:rules).returns(rules)
  end

  describe :add_tags do
    it 'tags the job according to the rules' do
      job.log.update_attributes!(content: log)
      job.reload.add_tags
      job.tags.should == 'rake_not_bundled,database_missing'
    end
  end
end
