require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for a Job::Test worker job' do
  include Support::ActiveRecord, Support::Formats

  describe 'for a push request' do
    let(:commit) { Factory(:commit, :ref => nil) }
    let(:job)    { Factory(:test, :commit => commit) }

    it 'contains the expected data' do
      json_for_worker(job).should == {
        'type' => 'test',
        'build' => {
          'id' => job.id,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master'
        },
        'repository' => {
          'id' => job.repository_id,
          'slug' => 'svenfuchs/minimal',
          'source_url' => 'git://github.com/svenfuchs/minimal.git'
        },
        'config' => {
          'rvm' => '1.8.7',
          'gemfile' => 'test/Gemfile.rails-2.3.x'
        },
        'queue' => 'builds.common'
      }
    end
  end

  describe 'for a pull request' do
    let(:commit) { Factory(:commit, :ref => 'refs/pull/180/merge') }
    let(:job)    { Factory(:test, :commit => commit) }

    it 'contains the expected data' do
      json_for_worker(job).should == {
        'type' => 'test',
        'build' => {
          'id' => job.id,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master',
          'ref'    => 'refs/pull/180/merge'
        },
        'repository' => {
          'id' => job.repository_id,
          'slug' => 'svenfuchs/minimal',
          'source_url' => 'git://github.com/svenfuchs/minimal.git'
        },
        'config' => {
          'rvm' => '1.8.7',
          'gemfile' => 'test/Gemfile.rails-2.3.x'
        },
        'queue' => 'builds.common'
      }
    end
  end
end
