require 'spec_helper'

describe Build::Messages do
  include Build::Messages

  describe :result_key do
    it 'returns :pending if the build is pending' do
      data = { state: :created, previous_state: nil }
      result_key(data).should == :pending
    end

    it 'returns :passed if the build has passed for the first time' do
      data = { state: :passed, previous_state: nil }
      result_key(data).should == :passed
    end

    it 'returns :failed if the build has failed for the first time' do
      data = { state: :failed, previous_state: nil }
      result_key(data).should == :failed
    end

    it 'returns :passed if the build has passed again' do
      data = { state: :passed, previous_state: :passed }
      result_key(data).should == :passed
    end

    it 'returns :broken if the build was broken' do
      data = { state: :failed, previous_state: :passed }
      result_key(data).should == :broken
    end

    it 'returns :fixed if the build was fixed' do
      data = { state: :passed, previous_state: :failed }
      result_key(data).should == :fixed
    end

    it 'returns :failing if the build has failed again' do
      data = { state: :failed, previous_state: :failed }
      result_key(data).should == :failing
    end

    it 'returns :errored if the build has errored' do
      data = { state: :errored, previous_state: :failed }
      result_key(data).should == :errored
    end

    it 'returns :canceled if the build has canceled' do
      data = { state: :canceled, previous_state: :failed }
      result_key(data).should == :canceled
    end
  end
end
