require 'spec_helper'

describe Travis::Task do
  describe 'run_local?' do
    after :each do
      Travis::Task.run_local = nil
      Travis::Features.redis.set('feature:travis_tasks:disabled', nil)
    end

    it 'is true by default' do
      Travis::Task.run_local?.should be_true
    end

    it 'can be set to true manually' do
      Travis::Task.run_local = true
      Travis::Task.run_local?.should be_true
    end

    it 'can be set to true through a feature flag' do
      Travis::Features.deactivate_all(:travis_tasks)
      Travis::Task.run_local?.should be_true
    end

    it 'can be set to false through a feature flag' do
      Travis::Features.enable_for_all(:travis_tasks)
      Travis::Task.run_local?.should be_false
    end
  end
end

