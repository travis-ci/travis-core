require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for worker jobs' do
  include Support::ActiveRecord, Support::Formats

  let(:job) { Factory(:configure) }

  it 'Job::Configure' do
    json_for_worker(job).should == {
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
