require 'spec_helper'
require 'travis/sidekiq/build_request'

# This simulates Sidekiq build request jobs that raised an exception and were
# put to the retry queue.
#
# Capture retry jobs from Sidekiq in an app, copy the file to this reposiotry's root dir.
#
# $ heroku run bundle exec ruby -e "'require \"travis\"; Sidekiq.configure_client { |c| c.redis = Travis.config.redis.merge(size: 1, namespace: Travis.config.sidekiq.namespace) }; Sidekiq::RetrySet.new.each { |j| p j.args }; sleep 1'" -rproduction > retries.rb
#
# Then uncomment and run the specs below.
#
# TODO: automatically filter out jobs that aren't build requests (e.g. webhook tasks)

describe 'Re-run Sidekiq payloads from retry jobs' do
  include Support::ActiveRecord, Support::Log

  let(:payload) { MultiJson.decode(params['payload']) }
  let(:request) { Travis::Sidekiq::BuildRequest.new.perform(params) }

  before :each do
    Travis::Metrics.stubs(:meter)
  end

  lines = File.read('retries.rb').split("\n")
  lines = lines.select { |line| !line.include?('Travis::') }

  lines.each_with_index do |line, ix|
    describe 'simulating retry' do
      let(:params)  { eval(line).first }

      before(:each) do
        owner_name = payload['repository']['owner']['login'] || payload['repository']['owner']['name']
        name = payload['repository']['name']
        github_id = payload['repository']['id']
        Factory(:repository, name: name, owner_name: owner_name, github_id: github_id)
      end

      it ix.to_s do
        log = capture_log { request }
        puts log.gsub(/(I|W|E) /, "\n" + '\1 ').strip
      end
    end
  end
end
