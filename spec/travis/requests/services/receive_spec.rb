require 'spec_helper'

# TODO this is really an integration test. should move it
# somewhere else and add unit tests

describe Travis::Requests::Services::Receive do
  include Support::ActiveRecord

  let(:owner)   { User.first || Factory(:user) }
  let(:service) { described_class.new(params) }
  let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:request) { service.run }

  before :each do
    Request.any_instance.stubs(:configure)
    Request.any_instance.stubs(:start)
  end

  describe 'without repository data' do
    before { payload['repository'] = nil }

    context 'a push' do
      let(:params) { { :event_type => 'push', :github_guid => 'abc123', :payload => payload } }

      it 'raises validation error' do
        message = "Repository data is not present in payload, github-guid=abc123, event-type=push"
        expect { request }.to raise_error Travis::Requests::Services::Receive::PayloadValidationError, message
      end
    end

    context 'a pull request' do
      let(:params) { { :event_type => 'pull_request', :github_guid => 'abc123', :payload => payload } }

      it 'raises validation error' do
        message = "Repository data is not present in payload, github-guid=abc123, event-type=pull_request"
        expect { request }.to raise_error Travis::Requests::Services::Receive::PayloadValidationError, message
      end
    end
  end

  shared_examples_for 'creates a commit' do
    it 'creates a commit' do
      expect { request }.to change(Commit, :count).by(1)
    end
  end

  shared_examples_for 'creates a request' do
    it 'creates a request for the given payload' do
      expect { request }.to change(Request, :count).by(1)
    end

    it 'sets the payload to the request' do
      request.payload.should == payload
    end
  end

  describe 'a github push event' do
    let(:params) { { :event_type => 'push', :payload => payload } }

    describe 'for repository belonging to a user' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }

      before(:each) do
        Factory(:repository, name: 'svenfuchs', owner_name: 'gem-release', github_id: 100)
      end

      it_should_behave_like 'creates a request'
    end

    describe 'with disabled pushes' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['travis-core']) }

      before do
        repo = Factory.create(:repository, name: 'travis-core', owner_name: 'travis-ci', github_id: 111)
        repo.settings.merge('build_pushes' => false)
      end

      it 'rejects the commit' do
        expect { request }.not_to change(Build, :count)
      end
    end

    describe 'for repository belonging to an organization' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['travis-core']) }

      before(:each) { Factory(:repository, name: 'travis-core', owner_name: 'travis-ci', github_id: 111) }
      it_should_behave_like 'creates a request'
    end
  end

  describe 'a github pull-request event' do
    describe 'for a repository that belongs to an organization' do
      let(:params)  { { :event_type => 'pull_request', :payload => payload } }
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['pull-request']) }

      before(:each) { Factory(:repository, name: 'test-repo-1', owner_name: 'travis-repos', github_id: 1615549) }

      it_should_behave_like 'creates a request'

      it 'sets the comments_url to the request' do
        request.comments_url.should == 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments'
      end
    end
  end

  describe 'an api request' do
    let(:params)  { { :event_type => 'api', :payload => payload } }
    let(:payload) { API_PAYLOADS['custom'] }

    before(:each) do
      Factory(:user, :id => 1, :login => 'svenfuchs', github_id: 2208)
      Factory(:repository, :github_id => 592533, :name => 'gem-release')
    end

    it_should_behave_like 'creates a request'
  end
end

describe Travis::Requests::Services::Receive::Instrument do
  include Support::ActiveRecord

  let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:service)   { Travis::Requests::Services::Receive.new(event_type: 'push', payload: payload) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
    Factory(:repository, name: 'svenfuchs', owner_name: 'gem-release', github_id: 100)
    Request.any_instance.stubs(:configure)
    Request.any_instance.stubs(:start)
    Travis::Notification.publishers.replace([publisher])
    service.run
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.requests.services.receive.run:completed',
      message: 'Travis::Requests::Services::Receive#run:completed type="push"',
      data: {
        type: 'push',
        accept?: true,
        payload: payload
      }
    )
  end
end
