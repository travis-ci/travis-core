require File.expand_path 'lib/travis/github_api'
require 'support/mocha'

describe Travis::GithubApi do

  describe ".add_service_hook" do

    it "should add a service hook" do
      client_stub = stub.tap do |client|
        client.expects(:subscribe_service_hook).with('owner/name', 'Travis', {})
      end

      Octokit::Client.stubs(:new)
        .with(:oauth_token => 't0k3n')
        .returns(client_stub)

      Travis::GithubApi.add_service_hook('owner', 'name', 't0k3n', {})
    end

    pending "should raise an error when a service hook error occurs" do

    end

    pending "should raise an error when an unauthorized error occurs" do

    end

  end

end
