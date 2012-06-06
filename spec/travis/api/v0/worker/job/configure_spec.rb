require 'spec_helper'

describe Travis::Api::V0::Worker::Job::Configure do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V0::Worker::Job::Configure.new(test).data }

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
