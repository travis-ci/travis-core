# encoding: utf-8
require 'spec_helper'

describe Repository::Settings do
  let(:repo) { stub('repository') }

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

      repo.expects('settings=')
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

      repo.expects('settings=')
      settings.merge('campfire' => { 'api_key' => { 'type' => 'password', 'value' => '∗1∗∗∗1' } })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => { 'type' => 'password', 'value' => 'abc123' },
        'domain'  => 'travis'
      }

      repo.expects('settings=')
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

      repo.expects('settings=')
      settings.merge('campfire' => { 'api_key' => { 'type' => 'password', 'value' => '*****' } })

      settings['campfire'].should == {
        'room_id' => 1,
        'api_key' => { 'type' => 'password', 'value' => '*****' },
        'domain'  => 'travis'
      }
     end
  end

  describe '#obfuscated' do
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

      settings.to_hash.should == json
    end
  end
end
#
