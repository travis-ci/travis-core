require 'spec_helper'

class BuildMock
  include Build::States
  class << self; def name; 'Build'; end; end
  attr_accessor :state, :started_at, :finished_at, :duration
  def denormalize(*); end
end

describe Build::States do
  include Support::ActiveRecord

  let(:build) { BuildMock.new }

  describe 'events' do
    describe 'create' do
      xit 'notifies observers' do
        Travis::Event.expects(:dispatch).with { |event| event == 'build:created' }
        Factory(:build)
      end
    end

    describe 'start' do
      let(:data) { WORKER_PAYLOADS['job:test:start'] }

      describe 'when the build is not already started' do
        it 'sets the state to :started' do
          build.start(data)
          build.state.should == :started
        end

        it 'denormalizes attributes' do
          build.expects(:denormalize)
          build.start(data)
        end

        it 'notifies observers' do
          Travis::Event.expects(:dispatch).with('build:started', build, data)
          build.start(data)
        end
      end

      describe 'when the build is already started' do
        before :each do
          build.state = :started
        end

        it 'does not denormalize attributes' do
          build.expects(:denormalize).never
          build.start(data)
        end

        it 'does not notify observers' do
          Travis::Event.expects(:dispatch).never
          build.start(data)
        end
      end
    end

    describe 'finish' do
      let(:data) { WORKER_PAYLOADS['job:test:finish'] }

      describe 'when the matrix is not finished' do
        before(:each) do
          build.stubs(matrix_finished?: false)
        end

        it 'does not change the state' do
          build.finish(data)
          build.state.should == :created
        end

        it 'does not denormalizes attributes' do
          build.expects(:denormalize).never
          build.finish(data)
        end

        it 'does not notify observers' do
          Travis::Event.expects(:dispatch).never
          build.finish(data)
        end
      end

      describe 'when the matrix is finished' do
        before(:each) do
          build.stubs(matrix_finished?: true, matrix_state: :passed, matrix_duration: 30)
          build.expects(:save!)
        end

        it 'sets the state to the matrix state' do
          build.finish(data)
          build.state.should == :passed
        end

        it 'calculates the duration based on the matrix durations' do
          build.finish(data)
          build.duration.should == 30
        end

        it 'denormalizes attributes' do
          build.expects(:denormalize).with(:finish, data)
          build.finish(data)
        end

        it 'notifies observers' do
          Travis::Event.expects(:dispatch).with('build:finished', build, data)
          build.finish(data)
        end
      end
    end
  end
end
