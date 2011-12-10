require 'spec_helper'
require 'travis/cli'
require 'stringio'

describe Travis::Cli::Deploy do
  let(:command) { Travis::Cli::Deploy.any_instance }

  def invoke(remote, options = {})
    capture_stdout do
      Travis::Cli::Deploy.new.invoke('deploy', [remote], options)
    end
  end

  before :each do
    Travis::Cli::Config
    Thor.class_eval { (class << self; self; end).send(:define_method, :method_added) { |*| } }
    command.stubs(:system)
    command.stubs(:branch).returns('master')
  end

  describe 'with a clean working directory' do
    before :each do
      command.stubs(:clean?).returns(true)
    end

    describe 'given remote "production"' do
      it 'switches to the production branch' do
        command.expects(:system).with('git checkout production')
        invoke 'production'
      end

      it 'resets the production branch to the current branch' do
        command.expects(:system).with('git reset --hard master')
        invoke 'production'
      end

      it 'pushes the production branch to origin' do
        command.expects(:system).with('git push origin production')
        invoke 'production'
      end

      it 'switches back to the previous branch' do
        command.expects(:system).with('git checkout master')
        invoke 'production'
      end

      it 'tags the current commit ' do
        command.expects(:system).with { |cmd| cmd =~ /git tag -a 'deploy .*' -m 'deploy .*'/ }
        invoke 'production'
      end

      it 'pushes the tag to origin' do
        command.expects(:system).with('git push --tags')
        invoke 'production'
      end

      it 'pushes to the given remote' do
        command.expects(:system).with('git push production HEAD:master')
        invoke 'production'
      end
    end

    describe 'given the remote "staging"' do
      it 'does not switch to the production branch' do
        command.expects(:system).with('git checkout production').never
        invoke 'staging'
      end

      it 'does not tag the current commit if the given remote is "staging"' do
        command.expects(:system).with { |cmd| cmd =~ /git tag -a 'deploy .*' -m 'deploy .*'/ }.never
        invoke 'staging'
      end

      it 'pushes to the given remote' do
        command.expects(:system).with('git push staging HEAD:master')
        invoke 'staging'
      end
    end

    it 'migrates the database if --migrate is given' do
      command.expects(:system).with('heroku run rake db:migrate -r production')
      invoke 'production', :migrate => true
    end

    it 'configures the application if --configure is given' do
      Travis::Cli::Config.any_instance.expects(:sync).with('production')
      invoke 'production', :configure => true
    end
  end

  describe 'with a dirty working directory' do
    before :each do
      command.stubs(:clean?).returns(false)
    end

    it 'outputs an error message' do
      command.expects(:error).with('There are unstaged changes.')
      invoke 'production'
    end
  end
end

