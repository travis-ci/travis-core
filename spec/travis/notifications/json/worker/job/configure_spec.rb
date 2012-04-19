require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Notifications::Json::Worker::Job::Configure do
  include Support::ActiveRecord, Support::Formats

  let(:repository) { Repository.new(:owner_name => 'svenfuchs', :name => 'minimal') }
  let(:commit)     { Factory(:commit, :repository => repository) }
  let(:job)        { Factory(:configure, :commit => commit) }
  let(:data)       { Travis::Notifications::Json::Worker::Job::Configure.new(job).data }

  it 'build' do
    data.should == {
      'type' => 'configure',
      'build' => {
        'id' => job.id,
        'commit' => '62aae5f70ceee39123ef',
        'branch' => 'master',
        'config_url' => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml'
      },
      'repository' => {
        'id' => job.repository_id,
        'slug' => 'svenfuchs/minimal'
      },
      'queue' => 'builds.configure'
    }
  end
end
