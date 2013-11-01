# encoding: utf-8
require 'spec_helper'

describe Repository::Settings do
  let(:repo) { stub('repository') }

  describe '#get' do
    it 'fetches a given path' do
      json = { 'foo' => { 'bar' => { 'baz' => 'qux' } } }
      settings = Repository::Settings.new(repo, json)
      settings.get('foo.bar.baz').should == 'qux'
    end

    it 'returns nil when path is not available' do
      settings = Repository::Settings.new(repo, {})
      settings.get('foo.bar.baz').should == nil
    end
  end

  describe '.defaults=' do
    it 'saves defaults to redis' do
      described_class.defaults = { 'foo' => 'bar' }

      Travis.redis.get(described_class.settings_key).should == { 'foo' => 'bar' }.to_json
    end
  end

  it 'allows to load from nil' do
    settings = Repository::Settings.new(repo, nil)
    settings.to_hash == {}
  end

  describe 'save' do
    it 'saves settings to the repository' do
      repo.expects('settings=').with({'foo' => 'bar'}.to_json)
      repo.expects('save')

      settings = Repository::Settings.new(repo, 'foo' => 'bar')
      settings.save
    end
  end

  describe '#replace' do
    it 'rejects asterisked values' do
      settings = Repository::Settings.new(repo, {})

      settings.expects(:save)
      settings.replace('campfire' => {
        'room_id' => 1,
        'domain'  => 'travis',
        'api_key' => { 'type' => 'password', 'value' => '∗1∗∗∗1' } })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => { 'type' => 'password' },
        'domain'  => 'travis'
      }

      settings.expects(:save)
      settings.replace('foo' => ['∗∗∗∗1', 'bar', '2∗∗'])

      settings['foo'].should == ['bar']
    end
  end

  describe '#merge' do
    it 'merges individual fields' do
      json = {
        'campfire' => {
          'room_id' => 1,
          'api_key' => 'abc123',
          'domain'  => 'travis'
        }
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:save)
      settings.merge('campfire' => { 'api_key' => 'def456' })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => 'def456',
        'domain'  => 'travis'
      }
     end

    it 'rejects asterisked values' do
      json = {
        'campfire' => {
          'room_id' => 1,
          'api_key' => { 'type' => 'password', 'value' => 'abc123' },
          'domain'  => 'travis'
        }
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:save)
      settings.merge('campfire' => { 'api_key' => { 'type' => 'password', 'value' => '∗1∗∗∗1' } })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => { 'type' => 'password', 'value' => 'abc123' },
        'domain'  => 'travis'
      }

      settings.expects(:save)
      settings.merge('foo' => ['∗∗∗∗1', 'bar', '2∗∗'])

      settings['foo'].should == ['bar']
    end

    it 'does not reject regular asterisk' do
      json = {
        'campfire' => {
          'room_id' => 1,
          'api_key' => { 'type' => 'password', 'value' => 'abc123' },
          'domain'  => 'travis'
        }
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:save)
      settings.merge('campfire' => { 'api_key' => { 'type' => 'password', 'value' => '*****' } })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => { 'type' => 'password', 'value' => '*****' },
        'domain'  => 'travis'
      }
     end
  end

  describe 'to_hash' do
    it 'returns defaults, overwritten by settings' do
      json = {
        'builds' => {
          'only_with_travis_yml' => true
        }
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:defaults).returns(
        'builds' => {
          'only_with_travis_yml' => false,
          'build_pr_on_synchronize' => true
        }
      )

      settings.obfuscated.should == {
        'builds' => {
          'only_with_travis_yml' => true,
          'build_pr_on_synchronize' => true
        }
      }
    end
  end

  describe '#obfuscated' do
    it 'returns defaults, overwritten by settings' do
      json = {
        'builds' => {
          'only_with_travis_yml' => true
        }
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:defaults).returns(
        'builds' => {
          'only_with_travis_yml' => false,
          'build_pr_on_synchronize' => true
        }
      )

      settings.obfuscated.should == {
        'builds' => {
          'only_with_travis_yml' => true,
          'build_pr_on_synchronize' => true
        }
      }
    end

    it 'changes all of the password values into obfuscated values' do
      json = {
        'campfire' => {
          'room_id' => 1,
          'api_key' => { 'type' => 'password', 'value' => 'abc123' },
        },
        'foo' => [{'bar' => {'type' => 'password', 'value' => '123'}}, {'type' => 'foobar', 'value' => 'foobar'}, 'bar']
      }
      settings = Repository::Settings.new(repo, json)

      settings.obfuscated.should == {
        'campfire' => {
          'room_id' => 1,
          'api_key' => { 'type' => 'password', 'value' => '∗∗∗∗∗∗' },
        },
        'foo' => [{'bar' => {'type' => 'password', 'value' => '∗∗∗'}}, {'type' => 'foobar', 'value' => 'foobar'}, 'bar']
      }

      # ensure if we're not modyfing original hash
      settings.to_hash['campfire']['api_key']['value'].should == 'abc123'
      settings.to_hash['foo'].first['bar']['value'].should == '123'
    end
  end
end
