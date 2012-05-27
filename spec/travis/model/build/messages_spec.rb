require 'spec_helper'

describe Build::Messages do
  let(:klass) { Class.new { include Build::Messages } }

  def create_build(attrs)
    klass.new.tap do |build|
      attrs.each { |name, value| build.stubs(name).returns(value) }
    end
  end

  describe :result_key do
    it 'returns :pending if the build is pending' do
      build = create_build(:state => :created)
      build.result_key.should == :pending
    end

    it 'returns :passed if the build has passed for the first time' do
      build = create_build(:state => :finished, :previous_result => nil, :result => 0)
      build.result_key.should == :passed
    end

    it 'returns :failed if the build has failed for the first time' do
      build = create_build(:state => :finished, :previous_result => nil, :result => 1)
      build.result_key.should == :failed
    end

    it 'returns :passed if the build has passed again' do
      build = create_build(:state => :finished, :previous_result => 0, :result => 0)
      build.result_key.should == :passed
    end

    it 'returns :broken if the build was broken' do
      build = create_build(:state => :finished, :previous_result => 0, :result => 1)
      build.result_key.should == :broken
    end

    it 'returns :fixed if the build was fixed' do
      build = create_build(:state => :finished, :previous_result => 1, :result => 0)
      build.result_key.should == :fixed
    end

    it 'returns :still_failing if the build has failed again' do
      build = create_build(:state => :finished, :previous_result => 1, :result => 1)
      build.result_key.should == :still_failing
    end
  end
end
