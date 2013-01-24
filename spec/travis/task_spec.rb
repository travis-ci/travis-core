require 'spec_helper'

describe Travis::Task do
  let(:subject) { described_class }

  describe 'run_local?' do
    after :each do
      subject.run_local = nil
      Travis::Features.redis.set('feature:travis_tasks:disabled', nil)
    end

    it 'is true by default' do
      subject.run_local?.should be_true
    end

    it 'can be set to true manually' do
      subject.run_local = true
      subject.run_local?.should be_true
    end

    it 'can be set to true on a child class without affecting other classes' do
      Travis::Features.enable_for_all(:travis_tasks)
      pusher = Travis::Addons::Pusher::Task
      email  = Travis::Addons::Email::Task
      pusher.run_local = true
      pusher.run_local?.should be_true
      email.run_local?.should be_false
      subject.run_local?.should be_false
    end

    it 'can be set to true through a feature flag' do
      Travis::Features.deactivate_all(:travis_tasks)
      subject.run_local?.should be_true
    end

    it 'can be set to false through a feature flag' do
      Travis::Features.enable_for_all(:travis_tasks)
      subject.run_local?.should be_false
    end
  end
end

