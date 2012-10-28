require 'spec_helper'

describe Request::States do
  include Support::ActiveRecord

  let(:owner)      { User.new(:login => 'joshk') }
  let(:repository) { Repository.new(:name => 'travis-ci', :owner => owner, :owner_name => 'travis-ci') }
  let(:commit)     { Commit.new(:repository => repository, :commit => '12345', :branch => 'master', :message => 'message', :committed_at => Time.now) }
  let(:request)    { Request.new(:repository => repository, :commit => commit) }

  let(:approval)   { Request::Approval.any_instance }
  let(:github)     { Travis::Services::Github::FetchConfig.any_instance }
  let(:config)     { { :from => '.travis.yml' } }

  before :each do
    github.stubs(:run).returns(config)
    request.stubs(:add_build) # can't stub on the stupic association?
  end

  it 'has the state :created when just created' do
    request.state.should == :created
  end

  describe 'start' do
    describe 'with an accepted request' do
      before :each do
        approval.stubs(:accepted?).returns(true)
      end

      it 'configures the request' do
        request.expects(:configure)
        request.start
      end

      it 'finishes the request' do
        request.expects(:finish)
        request.start
      end

      it 'sets the state to started' do
        request.start
        request.was_started?.should be_true
      end

      it 'sets the result to :accepted' do
        request.start
        request.result.should == :accepted
      end
    end

    describe 'with a rejected request' do
      before :each do
        approval.stubs(:accepted?).returns(false)
      end

      it 'does not configure the request' do
        request.expects(:fetch_config).never
        request.start
      end

      it 'finishes the request' do
        request.expects(:finish)
        request.start
      end

      it 'sets the state to started' do
        request.start
        request.was_started?.should be_true
      end

      it 'sets the result to :rejected' do
        request.start
        request.result.should == :rejected
      end
    end
  end

  describe 'configure' do
    it 'fetches the .travis.yml config from Github' do
      github.expects(:run).returns(config)
      request.configure
    end

    it 'stores the config on the request' do
      request.configure
      request.config.should == config
    end

    it 'sets the state to configured' do
      request.configure
      request.was_configured?.should be_true
    end
  end

  describe 'finish' do
    before :each do
      request.stubs(:config).returns('.configured' => true)
    end

    describe 'with an approved request' do
      before :each do
        approval.stubs(:approved?).returns(true)
      end

      it 'builds the build' do
        request.expects(:add_build)
        request.finish
      end

      it 'sets the state to finished' do
        request.finish
        request.should be_finished
      end
    end

    describe 'with an unapproved request' do
      before :each do
        approval.stubs(:approved?).returns(false)
      end

      it 'does not build the build' do
        request.expects(:add_build).never
        request.finish
      end

      it 'sets the state to finished' do
        request.finish
        request.should be_finished
      end
    end
  end

  describe 'start!' do
    before :each do
      request.stubs(:config).returns('.configured' => true)
      approval.stubs(:approved?).returns(true)
    end

    it 'finally sets the state to finished' do
      request.repository.save!
      request.repository_id = request.repository.id
      request.save!
      request.start!
      request.reload.should be_finished
    end
  end
end
