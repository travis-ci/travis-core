# encoding: utf-8
require 'spec_helper'

describe Travis::DefaultSettings do
  let(:settings) do
    klass = Class.new(Travis::Settings) {
      include Travis::DefaultSettings

      add_setting :foo, :string, default: 'bar'
    }
    klass.new
  end
  describe 'getting properties' do
    it 'fetches a given path from default settings' do
      settings.foo.should == 'bar'
    end
  end

  it 'doesn\'t allow to merge anything' do
    expect {
      settings.merge({})
    }.to raise_error(/merge is not supported/)
  end

  it 'doesn\'t allow to set any values' do
    expect {
      settings.foo = 'bar'
    }.to raise_error(/setting values is not supported/)
  end
end
