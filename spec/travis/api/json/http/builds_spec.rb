require 'spec_helper'
require 'support/active_record'
require 'travis/api'

describe Travis::Api::Json::Http::Builds do
  include Support::ActiveRecord, Support::Formats

  let(:builds) { [build] }
  let(:build)  { Factory(:build, :matrix => [test], :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] }) }
  let(:test)   { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }, :started_at => Time.now.utc, :finished_at => Time.now.utc) }
  let(:data)   { Travis::Api::Json::Http::Builds.new(builds).data }

  before :each do
    build.request.event_type = 'push'
  end

  it 'builds' do
    data.first.should == {
      'id' => build.id,
      'event_type' => 'push', # on the build api this probably should be just 'pull_request' => true or similar
      'repository_id' => build.repository_id,
      'number' => 2,
      'state' => :created,
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => nil,
      'result' => 0,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message'
    }
  end
end

