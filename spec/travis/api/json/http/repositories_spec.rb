require 'spec_helper'
require 'support/active_record'
require 'travis/api'

describe Travis::Api::Json::Http::Repositories do
  include Support::ActiveRecord, Support::Formats

  let(:repository)   { Factory(:repository) }
  let(:data)         { Travis::Api::Json::Http::Repositories.new([repository]).data }

  it 'data' do
    data.first.except('branch_summary').should == {
      'id' => repository.id,
      'slug' => 'svenfuchs/minimal',
      'description' => nil,
      'last_build_id' => repository.last_build_id,
      'last_build_number' => repository.last_build_number,
      'last_build_started_at' => json_format_time(Time.now.utc),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_status' => repository.last_build_status, # still here for backwards compatibility
      'last_build_result' => repository.last_build_status,
      'last_build_language' => nil,
      'last_build_duration' => nil
    }
  end

  xit 'branch_summary' do
    # 'branch_summary' => [{
    #   'build_id' => build.id,
    #   'commit' => build.commit.commit,
    #   'branch' => build.commit.branch,
    #   'message' => build.commit.message,
    #   'status' => build.status,
    #   'started_at' => '2010-11-12T12:30:00Z',
    #   'finished_at' => '2010-11-12T12:30:20Z',
    # }]
  end
end
