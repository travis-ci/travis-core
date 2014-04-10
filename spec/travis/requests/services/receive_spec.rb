require 'spec_helper'

# TODO this is really an integration test. should move it
# somewhere else and add unit tests

describe Travis::Requests::Services::Receive do
  include Support::ActiveRecord

  let(:owner)   { User.first || Factory(:user) }
  let(:service) { described_class.new(nil, params) }
  let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:request) { service.run }

  before :each do
    Request.any_instance.stubs(:configure)
    Request.any_instance.stubs(:start)
  end

  describe 'without a repository data' do
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

  shared_examples_for 'creates a request and repository' do
    it 'creates a request for the given payload' do
      expect { request }.to change(Request, :count).by(1)
    end

    it 'creates a repository' do
      expect { request }.to change(Repository, :count).by(1)
    end

    it 'sets the payload to the request' do
      request.payload.should == payload
    end
  end

  shared_examples_for 'sets the owner for the request and repository to the expected type and login' do |type, login|
    it 'sets the repository owner' do
      request.repository.owner.should be_a(type.camelize.constantize)
    end

    it 'sets the request owner' do
      request.owner.should be_a(type.camelize.constantize)
    end

    it_should_behave_like 'has the expected login for the request and repository owner', login
  end

  shared_examples_for 'has the expected login for the request and repository owner' do |login|
    it 'has the repository owner login' do
      request.repository.owner.login.should == login
    end

    it 'has the request owner login' do
      request.owner.login.should == login
    end
  end

  shared_examples_for 'creates a commit' do
    it 'creates a commit' do
      expect { request }.to change(Commit, :count).by(1)
    end
  end

  shared_examples_for 'creates an object from the github api' do |type, login, github_id|
    it 'creates the object' do
      expect { request }.to change(type.camelize.constantize, :count).by(1)
    end

    it 'calls the github api to populate the user' do
      resource = type == 'organization' ? "organizations/#{github_id}" : "user/#{github_id}"
      GH.expects(:[]).with(resource).returns('name' => login.camelize, 'login' => login, 'id' => github_id)
      request
    end
  end

  shared_examples_for 'does not create a user' do
    it 'does not create a user' do
      expect { request }.not_to change(User, :count)
    end
  end

  shared_examples_for 'does not create an organization' do
    it 'does not create an organization' do
      expect { request }.not_to change(Organization, :count)
    end
  end

  shared_examples_for 'a created request' do |type, login|
    it_should_behave_like 'creates a request and repository'
    it_should_behave_like 'sets the owner for the request and repository to the expected type and login', type, login
  end

  shared_examples_for 'adds a tag to a commit' do
    it 'adds a tag to a commit' do
      payload['ref'] = 'refs/tags/release-44'
      request.commit.tags.map(&:name).should == ['release-44']
    end
  end

  shared_examples_for 'adds a branch to a commit' do
    it 'adds branch to a commit' do
      payload['ref'] = 'refs/heads/development'
      request.commit.branches.map(&:name).should == ['development']
    end
  end

  describe 'a github push event' do
    let(:params) { { :event_type => 'push', :payload => payload } }

    describe 'for repository belonging to a user' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['gem-release']) }

      login = 'svenfuchs'
      type  = 'user'
      github_id = 2208

      describe 'if the user exists' do
        before(:each) { Factory(:user, :login => login, :github_id => 2208) }
        it_should_behave_like 'a created request', type, login
        it_should_behave_like 'does not create a user'
      end

      describe 'without existing commit' do
        it 'creates a commit' do
          expect { request }.to change(Commit, :count).by(1)
        end

        it_should_behave_like 'adds a tag to a commit'
        it_should_behave_like 'adds a branch to a commit'
      end

      describe 'with an existing commit' do
        it_should_behave_like 'adds a tag to a commit'
        it_should_behave_like 'adds a branch to a commit'

        it 'reuses the existing commit' do
          expect { request }.to change(Commit, :count).by(1)

          additional_request = nil
          expect {
            additional_request = described_class.new(nil, params).run
          }.to_not change(Commit, :count)
          additional_request.commit.should == request.commit
        end

        it 'does not reuse existing commit if it belongs to the other repository' do
          expect { request }.to change(Commit, :count).by(1)

          params[:payload]['repository']['id'] = params[:payload]['repository']['id'] + 1
          params[:payload]['repository']['name'] = 'new-repo'
          expect {
            described_class.new(nil, params).run
          }.to change(Commit, :count).by(1)
        end
      end

      describe 'if the user does not exist' do
        before(:each) { User.delete_all }
        it_should_behave_like 'a created request', type, login
        it_should_behave_like 'creates an object from the github api', type, login, github_id
      end
    end

    describe 'with disabled pushes' do
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['travis-core']) }

      login = 'travis-ci'
      type  = 'organization'
      github_id = 639823

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

      login = 'travis-ci'
      type  = 'organization'
      github_id = 639823

      describe 'if the organization exists' do
        before(:each) { Factory(:org, :login => login, :github_id => 639823) }
        it_should_behave_like 'a created request', type, login, github_id
        it_should_behave_like 'does not create an organization'
      end

      describe 'if the organization does not exist' do
        before(:each) { Organization.delete_all }
        it_should_behave_like 'a created request', type, login, github_id
        it_should_behave_like 'creates an object from the github api', type, login, github_id
      end
    end
  end

  describe 'a github pull-request event' do
    describe 'for a repository that belongs to an organization' do
      let(:params)  { { :event_type => 'pull_request', :payload => payload } }
      let(:payload) { JSON.parse(GITHUB_PAYLOADS['pull-request']) }

      login = 'travis-repos'
      type  = 'organization'
      github_id = 864347

      describe 'if the organization exists' do
        before(:each) { Factory(:org, :login => login, github_id: 864347) }
        it_should_behave_like 'a created request', type, login, github_id
        it_should_behave_like 'does not create an organization'

        it 'sets the comments_url to the request' do
          request.comments_url.should == 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments'
        end
      end

      describe 'if the organization does not exist' do
        before(:each) { Organization.delete_all }
        it_should_behave_like 'a created request', type, login
        it_should_behave_like 'creates an object from the github api', type, login, github_id

        it 'sets the comments_url to the request' do
          request.comments_url.should == 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments'
        end
      end
    end
  end
end

describe Travis::Requests::Services::Receive::Instrument do
  include Support::ActiveRecord

  let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:service)   { Travis::Requests::Services::Receive.new(nil, event_type: 'push', payload: payload) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
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
