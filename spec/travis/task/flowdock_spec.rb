require 'spec_helper'

describe Travis::Task::Flowdock do
  include Travis::Testing::Stubs

  let(:io)     { StringIO.new }
  let(:http)   { Faraday::Adapter::Test::Stubs.new }
  let(:client) { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:data)   { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:flowdock_message) do
    <<-EOM
<ul>
<li><code><a href="https://github.com/svenfuchs/minimal">svenfuchs/minimal</a></code> build #2 has passed!</li>
<li>Branch: <code>master</code></li>
<li>Latest commit: <code><a href="https://github.com/svenfuchs/minimal/commit/62aae5f70ceee39123ef">62aae5f</a></code> by <a href="mailto:svenfuchs@artweb-design.de">Sven Fuchs</a></li>
<li>Change view: https://github.com/svenfuchs/minimal/compare/master...develop</li>
<li>Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}</li>
</ul>
    EOM
  end

  let(:flowdock_payload) do
    {
      :source       => 'Travis',
      :from_address => 'build+ok@flowdock.com',
      :subject      => 'svenfuchs/minimal build #2 has passed!',
      :content      => flowdock_message,
      :from_name    => 'CI',
      :project      => 'Build Status',
      :format       => 'html',
      :tags         => ['ci', 'ok'],
      :link         => "http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}"
    }
  end

  before do
    Travis::Features.start
    Travis.logger = Logger.new(io)
    Travis::Task::Flowdock.any_instance.stubs(:http).returns(client)
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run(targets, data)
    Travis::Task::Flowdock.new(data, :targets => targets).run
  end

  [
    '322fdcced7226b1d66396c68efedb0c1',
    '2c6a37b6058ce3eab96360188598bc97'
  ].each do |token|
    it "sends flowdock notifications to the Team Inbox with token #{token}" do
      targets = [token]

      host = "api.flowdock.com"
      path = "v1/messages/team_inbox/#{token}"

      http.post(path) do |env|
        env[:url].host.should == host
        env[:body].should == MultiJson.encode(flowdock_payload)
      end

      run(targets, data)
      http.verify_stubbed_calls
    end
  end

end

