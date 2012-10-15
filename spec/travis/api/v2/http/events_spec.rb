require 'spec_helper'

describe Travis::Api::V2::Http::Events do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Http::Events.new([event]).data }

  it 'events' do
    data['events'].first.should == {
      'id' => 1,
      'repository_id' => 1,
      'source_id' => 1,
      'source_type' => 'Request',
      'event' => 'request:finished',
      'data' => { 'result' => 'accepted' },
      'created_at' => json_format_time(Time.now.utc)
    }
  end
end

# describe 'Travis::Api::V2::Http::Events using Travis::Services::Events::FindAll' do
#   include Support::ActiveRecord
#
#   let!(:repo)  { Factory(:repository) }
#   let(:events) { Travis::Services::Events::FindAll.new(nil, :repository_id => repo.id).run }
#   let(:data)   { Travis::Api::V2::Http::Events.new(events).data }
#
#   before :each do
#     3.times { Factory(:event, :repository => repo) }
#   end
#
#   it 'queries' do
#     lambda { data }.should issue_queries(2)
#   end
# end


