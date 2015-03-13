require 'spec_helper'

# TODO this is really an integration test. should move it
# somewhere else and add unit tests

describe Travis::Requests::Services::Receive, truncation: true do
  include Support::ActiveRecord, Support::Log

  let(:owner)   { User.first || Factory(:user) }
  let(:service) { described_class.new(params) }
  let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:request) { service.run }

  before :each do
    Travis::Metrics.stubs(:meter)
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

    it 'logs a notice' do
      capture_log { request }.should include('Request finished.')
    end
  end

  describe 'a github push event' do
    let(:params) { { :event_type => 'push', :payload => payload } }

    describe 'for repository belonging to a user' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
      let(:owner)   { Factory(:user, login: 'svenfuchs', github_id: 2208) }
      let!(:repo)   { Factory(:repository, owner: owner, owner_name: owner.login, name: 'gem-release', github_id: 100) }

      it_should_behave_like 'creates a request'

      describe 'when no commits are present' do
        before :each do
          payload['commits'] = nil
        end

        it 'does not explode' do
          expect { request }.to_not raise_error
        end

        it 'logs a message' do
          capture_log { request }.should include('missing commit')
        end
      end
    end

    describe 'with disabled push events' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['travis-core']) }
      let(:owner)   { Factory(:org, login: 'travis-ci', github_id: 639823) }
      let!(:repo)   { Factory(:repository, owner: owner, owner_name: owner.login, name: 'travis-core', github_id: 111) }

      before do
        repo.settings.build_pushes = false
        repo.settings.save
      end

      it_should_behave_like 'creates a request'

      it 'rejects the request' do
        expect { request }.not_to change(Build, :count)
      end

      it 'logs a notice' do
        capture_log { request }.should include('pushes disabled')
      end
    end

    describe 'for repository belonging to an organization' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['travis-core']) }
      let(:owner)   { Factory(:org, login: 'travis-ci', github_id: 639823) }
      let!(:repo)   { Factory(:repository, owner: owner, owner_name: owner.login, name: 'travis-core', github_id: 111) }

      it_should_behave_like 'creates a request'
    end
  end

  describe 'a github pull-request event' do
    describe 'for a repository that belongs to an organization' do
      let(:params)  { { :event_type => 'pull_request', :payload => payload } }
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['pull-request']) }
      let(:owner)   { Factory(:org, login: 'travis-repos', github_id: 864347) }
      let!(:repo)   { Factory(:repository, owner: owner, owner_name: owner.login, name: 'test-repo-1', github_id: 1615549) }

      it_should_behave_like 'creates a request'

      it 'sets the comments_url to the request' do
        request.comments_url.should == 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments'
      end
    end
  end

  describe 'an API request' do
    let(:params)  { { :event_type => 'api', :payload => payload } }
    let(:owner)   { Factory(:user, id: 1, login: 'svenfuchs') }
    let!(:repo)   { Factory(:repository, github_id: 592533, owner: owner, owner_name: owner.login, name: 'gem-release') }

    describe 'giving the repo owner_id' do
      let(:payload) { { 'repository' => { 'owner_id' => owner.id, 'owner_type' => 'User', 'owner_name' => 'svenfuchs', 'name' => 'gem-release', 'id' => 111 }, 'user' => { 'id' => 1 } } }
      it_should_behave_like 'creates a request'
    end

    describe 'giving the repo owner_name' do
      let(:payload) { { 'repository' => { 'owner_name' => 'svenfuchs', 'name' => 'gem-release', 'id' => 111 }, 'user' => { 'id' => 1 } } }
      it_should_behave_like 'creates a request'
    end
  end

  describe 'with a repository that does not exist on our side' do
    let(:params) { { :event_type => 'push', :github_guid => 'abc123', :payload => payload } }

    it 'logs the validation error' do
      message = 'Repository not found'
      capture_log { request }.should include(message)
    end

    it 'meters the event' do
      Travis::Metrics.expects(:meter).with('request.receive.repository_not_found')
      request
    end
  end

  describe 'with a repository that does not have an owner (should never happen?)' do
    let(:params) { { :event_type => 'push', :github_guid => 'abc123', :payload => payload } }
    let!(:repo)  { Factory(:repository, owner: nil, owner_name: 'svenfuchs', name: 'gem-release', github_id: 100) }

    describe 'with an known owner referenced in the payload' do
      let!(:owner) { Factory(:user, id: 1, login: 'svenfuchs', github_id: 2208) }

      it 'updates the owner' do
        request
        repo.reload.owner.should == owner
      end

      it 'updates the owner_name' do
        request
        repo.reload.owner_name.should == owner.login
      end

      it 'logs a notice' do
        message = 'Repository owner updated for svenfuchs/gem-release: User#1 (svenfuchs)'
        capture_log { request }.should include(message)
      end
    end

    describe 'with an unknown owner referenced in the payload' do
      it 'logs the validation error' do
        message = 'The given repository owner could not be found'
        capture_log { request }.should include(message)
      end

      it 'meters the event' do
        Travis::Metrics.expects(:meter).with('request.receive.repository_owner_not_found')
        request
      end
    end
  end

  describe 'with a repository that has a different owner on our side (owner changed since last sync)' do
    let(:params) { { :event_type => 'push', :github_guid => 'abc123', :payload => payload } }
    let!(:owner) { Factory(:user, id: 2, login: 'travis', github_id: 2209) }
    let!(:repo)  { Factory(:repository, owner: owner, owner_name: 'travis', name: 'gem-release', github_id: 100) }

    describe 'with an known owner referenced in the payload' do
      let!(:sven) { Factory(:user, id: 1, login: 'svenfuchs', github_id: 2208) }

      it 'updates the owner' do
        request
        repo.reload.owner.should == sven
      end

      it 'updates the owner_name' do
        request
        repo.reload.owner_name.should == sven.login
      end

      it 'logs a notice' do
        message = 'Repository owner updated for svenfuchs/gem-release: User#1 (svenfuchs)'
        capture_log { request }.should include(message)
      end
    end

    describe 'with an unknown owner referenced in the payload' do
      it 'logs the validation error' do
        message = 'The given repository owner could not be found'
        capture_log { request }.should include(message)
      end

      it 'meters the event' do
        Travis::Metrics.expects(:meter).with('request.receive.repository_owner_not_found')
        request
      end
    end
  end

  describe 'without repository data' do
    before { payload['repository'] = nil }

    describe 'a push' do
      let(:params) { { :event_type => 'push', :github_guid => 'abc123', :payload => payload } }

      it 'logs the validation error' do
        message = "Repository data is not present in payload, github-guid=abc123, event-type=push"
        capture_log { request }.should include(message)
      end
    end

    describe 'a pull request' do
      let(:params) { { :event_type => 'pull_request', :github_guid => 'abc123', :payload => payload } }

      it 'logs the validation error' do
        message = "Repository data is not present in payload, github-guid=abc123, event-type=pull_request"
        capture_log { request }.should include(message)
      end
    end
  end

  describe 'catches GH:Errors' do
    let!(:owner)  { Factory(:user, id: 1, login: 'svenfuchs', github_id: 2208) }
    let(:params)  { { :event_type => 'push', :payload => JSON.parse(GITHUB_PAYLOADS['gem-release']) } }
    let(:error)   { GH::Error.new(stub(response: { status: 404 })) }
    let(:message) { 'payload for svenfuchs/gem-release could not be received as GitHub returned a 404' }

    before(:each) do
      Factory(:repository, name: 'svenfuchs', owner_name: 'gem-release', github_id: 100)
    end

    it 'during :accept?' do
      described_class::Push.any_instance.stubs(:validate!).raises(error)
      capture_log { request }.should include(message)
    end

    it 'during :create' do
      requests = stub('requests')
      requests.stubs(:create!).raises(error)
      Repository.any_instance.stubs(:requests).returns(requests) # ugh.
      capture_log { request }.should include(message)
    end
  end
end

describe Travis::Requests::Services::Receive::Instrument do
  include Support::ActiveRecord

  let!(:owner)    { Factory(:user, id: 1, login: 'svenfuchs', github_id: 2208) }
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
