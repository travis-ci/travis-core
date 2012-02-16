require 'spec_helper'
require 'support/payloads'
require 'support/active_record'

describe Request do
  include Support::ActiveRecord

  describe 'create' do
    let(:request) { Factory(:request).reload }

    it "also creates the request's configure job" do
      request.job.should be_instance_of(Job::Configure)
    end
  end

  shared_examples "a github event" do
    describe 'create_from' do
      it 'creates a request for a push payload' do
        request = Request.create_from(event_type, payload_data, 'token')

        request.payload.should == payload_data
        request.token.should == 'token'
      end
    end
    
    describe 'repository_for' do
      it 'creates a repository if it does not exist' do
        lambda { Request.repository_for(payload.repository) }.should change(Repository, :count).by(1)
      end

      it 'finds a repository if it exists' do
        Request.repository_for(payload.repository)
        lambda { Request.repository_for(payload.repository) }.should_not change(Repository, :count)
      end
      
    end
  end

  context 'push' do
    it_behaves_like "a github event"

    let(:payload_data) { GITHUB_PAYLOADS['gem-release'] }
    let(:payload) { Request::Payload::Github::Push.new(payload_data, 'token') }
    let(:event_type) { "push" }

    describe 'repository_for' do
      it 'sets the given payload attributes to the repository' do
        repository = Request.repository_for(payload.repository)
        repository.name.should == 'gem-release'
        repository.owner_name.should == 'svenfuchs'
        repository.owner_email.should == 'svenfuchs@artweb-design.de'
        repository.owner_name.should == 'svenfuchs'
        repository.url.should == 'http://github.com/svenfuchs/gem-release'
      end
    end

    describe 'commit_for' do
      let(:repository) { stub('repository', :id => 1) }

      it 'creates a commit for the given payload' do
        commit = Request.commit_for(payload, repository)

        commit.commit.should == '9854592'
        commit.message.should == 'Bump to 0.0.15'
        commit.branch.should == 'master'
        commit.committed_at.strftime("%Y-%m-%d %H:%M:%S").should == '2010-10-27 04:32:37'

        commit.committer_name.should == 'Sven Fuchs'
        commit.committer_email.should == 'svenfuchs@artweb-design.de'
        commit.author_name.should == 'Christopher Floess'
        commit.author_email.should == 'chris@flooose.de'
      end
    end
  end


  context 'pull_request' do
    it_behaves_like "a github event"

    let(:payload_data) { GITHUB_PAYLOADS['pull-request'] }
    let(:payload) { Request::Payload::Github::PullRequest.new(payload_data, 'token') }
    let(:event_type) { "pull_request" }
  end
end
