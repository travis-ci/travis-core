require 'spec_helper'

describe Request::States do
  include Support::ActiveRecord

  let(:repository) { Repository.new }
  let(:commit)     { Commit.new(:repository => repository) }
  let(:request)    { Request.new(:repository => repository, :commit => commit) }

  let(:approval)   { Request::Approval.any_instance }
  let(:github)     { Travis::Github::Config.any_instance }
  let(:config)     { { :from => '.travis.yml' } }

  before :each do
    github.stubs(:config).returns(config)
    request.stubs(:build_build) # can't stub on the stupic association?
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
    end

    describe 'with a rejected request' do
      before :each do
        approval.stubs(:accepted?).returns(false)
      end

      it 'does not configure the request' do
        request.expects(:configure).never
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
    end
  end

  describe 'configure' do
    it 'fetches the .travis.yml config from Github' do
      github.expects(:config).returns(config)
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
    describe 'with an approved request' do
      before :each do
        approval.stubs(:approved?).returns(true)
      end

      it 'builds the build' do
        request.expects(:build_build)
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
        request.expects(:build_build).never
        request.finish
      end

      it 'sets the state to finished' do
        request.finish
        request.should be_finished
      end
    end
  end
end
