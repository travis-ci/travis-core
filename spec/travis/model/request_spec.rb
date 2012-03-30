require 'spec_helper'
require 'support/payloads'
require 'support/active_record'
require 'support/webmock'

describe Request do
  include Support::ActiveRecord, Support::Webmock

  let(:payload) { GITHUB_PAYLOADS['gem-release'] }
  let(:owner)   { User.first || Factory(:user) }

  describe 'create' do
    let(:request) { Factory(:request).reload }

    it "creates the request's configure job" do
      request.job.should be_instance_of(Job::Configure)
    end
  end

  describe 'create_from' do
    let(:request) { Request.create_from(payload, 'token') }

    subject { lambda { request } }

    shared_examples_for 'creates a request and repository' do
      it 'creates a request for the given payload' do
        subject.should change(Request, :count).by(1)
      end

      it 'creates a repository' do
        subject.should change(Repository, :count).by(1)
      end

      it 'sets the payload to the request' do
        request.payload.should == payload
      end

      it 'sets the token to the request' do
        request.token.should == 'token'
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

    shared_examples_for 'creates a commit and configure job' do
      it 'creates a commit' do
        subject.should change(Commit, :count).by(1)
      end

      it 'creates a configure job' do
        subject.should change(Job::Configure, :count).by(1)
      end
    end

    shared_examples_for 'sets the owner for the configure job to the expected type and login' do |type, login|
      it 'sets the configure job owner' do
        request.job.owner.should be_a(type.camelize.constantize)
      end

      it_should_behave_like 'has the expected login for the configure job owner', login
    end

    shared_examples_for 'has the expected login for the configure job owner' do |login|
      it 'sets the configure job owner login' do
        request.job.owner.login.should == login
      end
    end

    shared_examples_for 'does not create a configure job' do
      it 'does not create a configure job' do
        subject.should_not change(Job::Configure, :count)
      end
    end

    shared_examples_for 'creates an object from the github api' do |type, name|
      it 'creates the object' do
        subject.should change(type.camelize.constantize, :count).by(1)
      end

      it 'calls the github api to populate the user' do
        subject.call
        assert_requested requests["https://api.github.com/#{type == 'organization' ? 'orgs' : 'users'}/#{name}"]
      end
    end

    shared_examples_for 'does not create a user' do
      it 'does not create a user' do
        subject.should_not change(User, :count)
      end
    end

    shared_examples_for 'does not create an organization' do
      it 'does not create an organization' do
        subject.should_not change(Organization, :count)
      end
    end

    shared_examples_for 'an accepted request' do |type, login|
      it_should_behave_like 'creates a request and repository'
      it_should_behave_like 'sets the owner for the request and repository to the expected type and login', type, login
      it_should_behave_like 'creates a commit and configure job'
      it_should_behave_like 'sets the owner for the configure job to the expected type and login', type, login
    end

    shared_examples_for 'a rejected request' do |type, login|
      it_should_behave_like 'creates a request and repository'
      it_should_behave_like 'sets the owner for the request and repository to the expected type and login', type, login
      it_should_behave_like 'does not create a configure job'
    end

    describe 'with a payload that contains a commit' do
      describe 'for repository belonging to a user' do
        let(:payload) { GITHUB_PAYLOADS['gem-release'] }
        login = 'svenfuchs'
        type  = 'user'

        describe 'if the user exists' do
          before(:each) { Factory(:user, :login => login) }
          it_should_behave_like 'an accepted request', type, login
          it_should_behave_like 'does not create a user'
        end

        describe 'if the user does not exist' do
          before(:each) { User.delete_all }
          it_should_behave_like 'an accepted request', type, login
          it_should_behave_like 'creates an object from the github api', type, login
        end
      end

      describe 'for repository belonging to an organization' do
        let(:payload) { GITHUB_PAYLOADS['travis-core'] }
        login = 'travis-ci'
        type  = 'organization'

        describe 'if the organization exists' do
          before(:each) { Factory(:org, :login => login) }
          it_should_behave_like 'an accepted request', type, login
          it_should_behave_like 'does not create an organization'
        end

        describe 'if the organization does not exist' do
          before(:each) { Organization.delete_all }
          it_should_behave_like 'an accepted request', type, login
          it_should_behave_like 'creates an object from the github api', type, login
        end
      end
    end

    describe 'with a payload that does not contain a commit' do
      describe 'for a repository belonging to a user' do
        let(:payload) { GITHUB_PAYLOADS['force-no-commit'] }
        login = 'LTe'
        type  = 'user'

        describe 'if the user exists' do
          before(:each) { Factory(:user, :login => login) }
          it_should_behave_like 'a rejected request', type, login
          it_should_behave_like 'does not create a user'
        end

        describe 'if the user does not exist' do
          before(:each) { User.delete_all }
          it_should_behave_like 'a rejected request', type, login
          it_should_behave_like 'creates an object from the github api', type, login
        end
      end

      describe 'for a repository belonging to an organization' do
        let(:payload) { GITHUB_PAYLOADS['travis-core-no-commit'] }
        login = 'travis-ci'
        type  = 'organization'

        describe 'if the organization exists' do
          before(:each) { Factory(:org, :login => login) }
          it_should_behave_like 'a rejected request', type, login
          it_should_behave_like 'does not create an organization'
        end

        describe 'if the organization does not exist' do
          before(:each) { User.delete_all }
          it_should_behave_like 'a rejected request', type, login
          it_should_behave_like 'creates an object from the github api', type, login
        end
      end
    end
  end

  describe 'repository_for' do
    let(:payload) { Request::Payload::Github.new(GITHUB_PAYLOADS['gem-release'], 'token') }

    subject { lambda { Request.repository_for(payload.repository, owner) } }

    it 'creates a repository if it does not exist' do
      subject.should change(Repository, :count).by(1)
    end

    it 'finds a repository if it exists' do
      subject.call
      subject.should_not change(Repository, :count)
    end

    it 'sets the given payload attributes to the repository' do
      repository = subject.call
      repository.name.should == 'gem-release'
      repository.owner_name.should == 'svenfuchs'
      repository.owner_email.should == 'svenfuchs@artweb-design.de'
      repository.owner_name.should == 'svenfuchs'
      repository.url.should == 'http://github.com/svenfuchs/gem-release'
    end
  end

  describe 'commit_for' do
    let(:payload) { Request::Payload::Github.new(GITHUB_PAYLOADS['gem-release'], 'token') }
    let(:repository) { stub('repository', :id => 1) }

    it 'creates a commit for the given payload' do
      commit = Request.commit_for(payload, repository)

      commit.commit.should  == '9854592'
      commit.message.should == 'Bump to 0.0.15'
      commit.branch.should  == 'master'
      commit.committed_at.strftime("%Y-%m-%d %H:%M:%S").should == '2010-10-27 04:32:37'

      commit.committer_name.should  == 'Sven Fuchs'
      commit.committer_email.should == 'svenfuchs@artweb-design.de'
      commit.author_name.should  == 'Christopher Floess'
      commit.author_email.should == 'chris@flooose.de'
    end
  end
end
