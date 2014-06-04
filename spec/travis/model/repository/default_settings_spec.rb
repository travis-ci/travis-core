# encoding: utf-8
require 'spec_helper'

describe Repository::DefaultSettings do
  describe 'getting properties' do
    it 'fetches a given path from default settings' do
      settings = Repository::DefaultSettings.new
      Repository::DefaultSettings.stubs(:defaults).returns(
        'build_pushes' => false
      )
      settings.build_pushes?.should == false
    end
  end

  it 'doesn\'t allow to merge anything' do
    settings = Repository::DefaultSettings.new
    expect {
      settings.merge({})
    }.to raise_error(/merge is not supported/)
  end

  it 'doesn\'t allow to replace anything' do
    settings = Repository::DefaultSettings.new
    expect {
      settings.replace({})
    }.to raise_error(/replace is not supported/)
  end

  it 'doesn\'t allow to set any values' do
    settings = Repository::DefaultSettings.new
    expect {
      settings['foo'] = 'bar'
    }.to raise_error(/setting values is not supported/)
  end
end
