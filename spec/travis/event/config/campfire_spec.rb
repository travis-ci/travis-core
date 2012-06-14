require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Campfire do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Campfire.new(build) }

  describe :send_on_finish? do
    before :each do
      build.stubs(:config => { :notifications => { :campfire => 'travis:apitoken@42' } })
    end

    it_behaves_like 'a build configuration'
  end

  describe :rooms do
    it 'returns an array of urls when given a string' do
      channels = 'travis:apitoken@42'
      build.stubs(:config => { :notifications => { :campfire => channels } })
      config.rooms.should == [channels]
    end

    it 'returns an array of urls when given an array' do
      channels = ['travis:apitoken@42']
      build.stubs(:config => { :notifications => { :campfire => channels } })
      config.rooms.should == channels
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      channels = 'travis:apitoken@42,evome:apitoken@44'
      build.stubs(:config => { :notifications => { :campfire => channels } })
      config.rooms.should == channels.split(' ').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      channels = { :rooms => %w(travis:apitoken&42), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :campfire => channels } })
      config.rooms.should == channels[:rooms]
    end
  end
end
