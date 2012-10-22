require 'spec_helper'

describe Travis::Task::Campfire do
  include Support::ActiveRecord
  include Travis::Testing::Stubs

  let(:io)      { StringIO.new }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }


  before do
    Travis::Features.start
    Travis.logger = Logger.new(io)
    Travis::Task::Campfire.any_instance.stubs(:http).returns(client)
    Travis::Features.stubs(:active?).returns(true)
    Repository.stubs(:find).returns(stub('repo'))
    Url.stubs(:shorten).returns(url)
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run(targets, build)
    data = Travis::Api.data(build, :for => 'event', :version => 'v2')
    Travis::Task::Campfire.new(data, :targets => targets).run
  end

  [['account', 'token'],
   ['my-account', 'my-token']].each do |account_details|
    account, token = *account_details
    it "sends campfire notifications to the #{account}:#{token}@1234" do
      targets = ["#{account}:#{token}@1234"]

      expect_campfire(account, 1234, token, [
        '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
        '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
        '[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
      ])
      run(targets, build)
      http.verify_stubbed_calls
    end
  end

  [['account', 'token'],
   ['my-account', 'my-token']].each do |account_details|
    account, token = *account_details
    it "sends custom campfire notifications to the #{account}:#{token}@1234" do
      build.obfuscated_config[:notifications] = { :campfire => { :template => ['[travis-ci] %{repository} %{commit}', '%{repository}' ]} }
      targets = ["#{account}:#{token}@1234"]

      expect_campfire(account, 1234, token, [
        '[travis-ci] svenfuchs/minimal 62aae5f',
        'svenfuchs/minimal'
      ])
      run(targets, build)
      http.verify_stubbed_calls
    end
  end

  def expect_campfire(account, room, token, body)
    host = "#{account}.campfirenow.com"
    path = "room/#{room}/speak.json"
    auth = Base64.encode64("#{token}:X").gsub("\n", '')

    body.each do |line|
      expected_http_body = MultiJson.encode({ :message => { :body => line } })
      http.post(path, expected_http_body) do |env|
        env[:request_headers]['authorization'].should == "Basic #{auth}"
        env[:url].host.should == host
        env[:body].should == expected_http_body
      end
    end
  end
end

