require 'spec_helper'

describe Travis::Api::V1::Http::Job do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::Job.new(test).data }

  context 'without log' do
    let(:data) do
      test = stub_test
      test.stubs :log => nil, :log_content => nil
      Travis::Api::V1::Http::Job.new(test).data
    end

    it 'returns null as a log content' do
      data['log'].should be_nil
    end
  end

  it 'data' do
    data.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'state' => 'finished',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'log' => 'the test log',
      'status' => 0, # still here for backwards compatibility
      'result' => 0,
      'build_id' => test.source_id,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'worker' => 'ruby3.worker.travis-ci.org:travis-ruby-4',
      'sponsor' => { 'name' => 'Railslove', 'url' => 'http://railslove.de' }
    }
  end

  context 'with encrypted env vars' do
    let(:test) do
      stub_test(:obfuscated_config => { 'env' => 'FOO=[secure]' })
    end

    it 'shows encrypted env vars in human readable way' do
      data['config']['env'].should == 'FOO=[secure]'
    end
  end
end
