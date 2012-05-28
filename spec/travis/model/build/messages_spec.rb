require 'spec_helper'

describe Build::Messages do
  include Build::Messages

  describe :result_key do
    it 'returns :pending if the build is pending' do
      result_key(:created, nil, nil).should == :pending
    end

    it 'returns :passed if the build has passed for the first time' do
      result_key(:finished, nil, 0).should == :passed
    end

    it 'returns :failed if the build has failed for the first time' do
      result_key(:finished, nil, 1).should == :failed
    end

    it 'returns :passed if the build has passed again' do
      result_key(:finished, 0, 0).should == :passed
    end

    it 'returns :broken if the build was broken' do
      result_key(:finished, 0, 1).should == :broken
    end

    it 'returns :fixed if the build was fixed' do
      result_key(:finished, 1, 0).should == :fixed
    end

    it 'returns :still_failing if the build has failed again' do
      result_key(:finished, 1, 1).should == :still_failing
    end
  end
end
