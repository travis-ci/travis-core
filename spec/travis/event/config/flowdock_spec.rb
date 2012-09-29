require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Flowdock do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Flowdock.new(build) }

  describe :send_on_finish? do
    before :each do
      build.stubs(:config => { :notifications => { :flowdock => 'd41d8cd98f00b204e9800998ecf8427e' } })
    end

    it_behaves_like 'a build configuration'
  end

  describe :rooms do
    it 'returns an array of urls when given a string' do
      channels = 'd41d8cd98f00b204e9800998ecf8427e'
      build.stubs(:config => { :notifications => { :flowdock => channels } })
      config.rooms.should == [channels]
    end

    it 'returns an array of urls when given an array' do
      channels = ['d41d8cd98f00b204e9800998ecf8427e']
      build.stubs(:config => { :notifications => { :flowdock => channels } })
      config.rooms.should == channels
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      channels = 'd41d8cd98f00b204e9800998ecf8427e,322fdcced7226b1d66396c68efedb0c1'
      build.stubs(:config => { :notifications => { :flowdock => channels } })
      config.rooms.should == channels.split(',').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      channels = { :rooms => %w(322fdcced7226b1d66396c68efedb0c1), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :flowdock => channels } })
      config.rooms.should == channels[:rooms]
    end
  end
end
