require 'spec_helper'

describe Build::Config do
  include Support::ActiveRecord

  # yaml:
  #   env:
  #     - FOO=foo
  #     - BAR=bar
  #
  # config:
  #   env: ['FOO=foo', 'BAR=bar']
  #
  it 'keeps the given env if it is an array' do
    config = YAML.load %(
      env:
        - FOO=foo
        - BAR=bar
    )
    config = Build::Config.new(config).normalize
    config.should == {
      env: ['FOO=foo', 'BAR=bar']
    }
  end

  # seems odd. is this on purpose?
  it 'normalizes an env vars hash to an array of strings' do
    config = YAML.load %(
      env:
        FOO: foo
        BAR: bar
    )
    Build::Config.new(config).normalize.should == {
      env: ['FOO=foo BAR=bar']
    }
  end

  it 'keeps env vars global and matrix arrays' do
    config = YAML.load %(
      env:
        global:
          - FOO=foo
          - BAR=bar
        matrix:
          - BAZ=baz
          - BUZ=buz
    )
    Build::Config.new(config).normalize.should == {
      global_env: ['FOO=foo', 'BAR=bar'],
      env: ['BAZ=baz', 'BUZ=buz']
    }
  end

  # seems odd. is this on purpose?
  it 'normalizes env vars global and matrix which are hashes to an array of strings' do
    config = YAML.load %(
      env:
        global:
          FOO: foo
          BAR: bar
        matrix:
          BAZ: baz
          BUZ: buz
    )
    Build::Config.new(config).normalize.should == {
      global_env: ['FOO=foo BAR=bar'],
      env: ['BAZ=baz BUZ=buz']
    }
  end

  it 'works fine if matrix part of env is undefined' do
    config = YAML.load %(
      env:
        global: FOO=foo
    )
    Build::Config.new(config).normalize.should == {
      global_env: ['FOO=foo']
    }
  end

  it 'works fine if global part of env is undefined' do
    config = YAML.load %(
      env:
        matrix: FOO=foo
    )
    Build::Config.new(config).normalize.should == {
      env: ['FOO=foo']
    }
  end

  # How would achieve this in YAML?
  it 'keeps matrix and global config as arrays, not hashes' do
    config = YAML.load %(
      env:
        global: FOO=foo
        matrix:
          -
            - BAR=bar
            - BAZ=baz
          - BUZ=buz
    )
    Build::Config.new(config).normalize.should == {
      global_env: ['FOO=foo'],
      env: [['BAR=bar', 'BAZ=baz'], 'BUZ=buz']
    }
  end
end
