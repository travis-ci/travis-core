require 'spec_helper'
require 'support/active_record'
require 'travis/api'

describe Travis::Api::Json::Http::Job::Tests do
  include Support::ActiveRecord, Support::Formats

  let(:tests) { [test] }
  let(:test)  { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }, :started_at => Time.now.utc, :finished_at => Time.now.utc) }
  let(:data)  { Travis::Api::Json::Http::Job::Tests.new(tests).data }

  it 'tests' do
    data.first.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
      'state' => :created,
      'allow_failure' => false
    }
  end
end

