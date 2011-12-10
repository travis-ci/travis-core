require 'spec_helper'
require 'travis/cli'
require 'stringio'

describe Travis::Cli::Config do
  let(:keychain) { Travis::Cli::Config::Keychain.any_instance }
  let(:command)  { Travis::Cli::Config.any_instance }

  def invoke(remote, options = {})
    capture_stdout do
      Travis::Cli::Config.new.invoke('sync', [remote], options)
    end
  end

  before :each do
    Travis::Cli::Config.class_eval { (class << self; self; end).send(:define_method, :method_added) { |*| } }
    command.stubs(:system)
    keychain.stubs(:fetch).returns('')
    File.stubs(:open)
  end

  describe 'sync' do
    before :each do
      command.stubs(:clean?).returns(true)
    end

    it 'fetches the config from the keychain' do
      keychain.expects(:fetch).returns('')
      invoke 'staging'
    end

    it 'writes the config to the local config file' do
      File.expects(:open).with { |path, mode| path =~ %r(config/travis.yml) }
      invoke 'staging'
    end

    it 'pushes the config to the given heroku remote' do
      command.expects(:run).with { |cmd| cmd =~ %r(heroku config:add travis_config=.* -r staging) }
      invoke 'staging'
    end

    it 'restarts the app when --restart is given' do
      command.expects(:restart)
      invoke 'staging', :restart => true
    end

    it 'does not restart the app when --restart is not given' do
      command.expects(:restart).never
      invoke 'staging'
    end
  end
end
