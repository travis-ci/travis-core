require 'spec_helper'

describe Build::Messages do
  include Build::Messages

  describe :result_key do
    it 'returns :pending if the build is pending' do
      data = { :state => :created, :previous_result => nil, :result => nil }
      result_key(data).should == :pending
    end

    it 'returns :passed if the build has passed for the first time' do
      data = { :state => :finished, :previous_result => nil, :result => 0 }
      result_key(data).should == :passed
    end

    it 'returns :failed if the build has failed for the first time' do
      data = { :state => :finished, :previous_result => nil, :result => 1 }
      result_key(data).should == :failed
    end

    it 'returns :passed if the build has passed again' do
      data = { :state => :finished, :previous_result => 0, :result => 0 }
      result_key(data).should == :passed
    end

    it 'returns :broken if the build was broken' do
      data = { :state => :finished, :previous_result => 0, :result => 1 }
      result_key(data).should == :broken
    end

    it 'returns :fixed if the build was fixed' do
      data = { :state => :finished, :previous_result => 1, :result => 0 }
      result_key(data).should == :fixed
    end

    it 'returns :still_failing if the build has failed again' do
      data = { :state => :finished, :previous_result => 1, :result => 1 }
      result_key(data).should == :failing
    end
  end
end
