require 'spec_helper'
require 'travis/cli'
require 'stringio'

describe Travis::Cli::Config::Keychain do
  let(:shell)    { stub('shell', :say => nil, :error => nil) }
  let(:keychain) { Travis::Cli::Config::Keychain.new('hub', shell) }

  before :each do
    keychain.stubs(:system)
    keychain.stubs(:`)
    keychain.stubs(:clean?).returns(true)
    File.stubs(:read)
  end

  def fetch
    capture_stdout do
      keychain.fetch
    end
  end

  describe 'fetch' do
    it 'changes to the keychain directory' do
      Dir.expects(:chdir).with { |path| path =~ %r(/travis-keychain$) }
      fetch
    end

    it 'errors if the working directory is dirty' do
      keychain.stubs(:clean?).returns(false)
      keychain.expects(:error).with('There are unstaged changes in your travis-keychain working directory.')
      fetch
    end

    it 'pulls changes from origin' do
      keychain.expects(:run).with('git pull')
      fetch
    end

    it 'reads the configuration' do
      File.expects(:read).with { |path| path =~ %r(config/travis.hub.yml$) }
      fetch
    end
  end
end

