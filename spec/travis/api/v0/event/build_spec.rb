require 'spec_helper'

describe Travis::Api::V0::Event::Build do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V0::Event::Build.new(build).data }

  it 'build' do
    data['build'].should == {
      'id' => 1,
      'repository_id' => 1,
      'commit_id' => 1,
      'job_ids' => [1, 2],
      'number' => 2,
      'pull_request' => false,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'state' => 'finished',
      'result' => 0,
      'previous_result' => 0,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60
    }
  end

  # it 'commit' do
  #   data['commit'].should == {
  #     'id' => 1,
  #     'sha' => '62aae5f70ceee39123ef',
  #     'branch' => 'master',
  #     'message' => 'the commit message',
  #     'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
  #     'committed_at' => json_format_time(Time.now.utc - 1.hour),
  #     'committer_email' => 'svenfuchs@artweb-design.de',
  #     'committer_name' => 'Sven Fuchs',
  #     'author_name' => 'Sven Fuchs',
  #     'author_email' => 'svenfuchs@artweb-design.de',
  #     'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
  #   }
  # end

  # context 'with encrypted env vars' do
  #   let(:build) do
  #     stub_build(:obfuscated_config => { 'env' => 'FOO=[secure]' })
  #   end

  #   it 'shows encrypted env vars in human readable way' do
  #     data['build']['config']['env'].should == 'FOO=[secure]'
  #   end
  # end
end

# describe 'Travis::Api::V0::Event::Build using Travis::Services::Builds::FindOne' do
#   include Support::ActiveRecord
#
#   let!(:record) { Factory(:build) }
#   let(:build)   { Travis::Services::Builds::FindOne.new(nil, :id => record.id).run }
#   let(:data)    { Travis::Api::V0::Event::Build.new(build).data }
#
#   it 'queries' do
#     lambda { data }.should issue_queries(5)
#   end
# end
#

