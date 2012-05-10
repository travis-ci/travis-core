require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Worker::Job::Configure do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Json::Worker::Job::Configure.new(test).data }

  before :each do
    test.stubs(:queue).returns('builds.configure')
  end

  it 'build' do
    data.should == {
      'type' => 'configure',
      'job' => {
        'id' => test.id,
        'commit' => '62aae5f70ceee39123ef',
        'branch' => 'master',
        'config_url' => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml'
      },
      # TODO remove this after workers respond to the job key
      'build' => {
        'id' => test.id,
        'commit' => '62aae5f70ceee39123ef',
        'branch' => 'master',
        'config_url' => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml'
      },
      'repository' => {
        'id' => test.repository_id,
        'slug' => 'svenfuchs/minimal'
      },
      'queue' => 'builds.configure'
    }
  end
end
