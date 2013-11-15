require 'spec_helper'

describe Travis::Github::Services::SyncUser::Hooks do
  include Support::ActiveRecord

  ACTIVE_HOOK = { 'name' => 'travis', 'domain' => '', 'active' => true }
  INACTIVE_HOOK = { 'name' => 'travis', 'domain' => '', 'active' => false }

  let(:user) { Factory(:user) }
  let(:repository) { Factory(:repository) }
  let(:gh) { Hash.new }
  let(:run) { -> { described_class.new(user, gh).run } }

  context 'user is marked as admin on one repository' do
    before do
      Permission.create!(user_id: user.id, repository_id: repository.id, admin: true, push: true, pull: true)
    end

    context 'hook is active on GitHub' do
      before do
        repository.update_attributes!(active: false)
        gh["/repositories/#{repository.github_id}/hooks"] = [ACTIVE_HOOK]
      end

      it 'marks repository as active' do
        run.should change { repository.reload.active }
        repository.active.should be_true
      end
    end

    context 'hook is inactive on GitHub' do
      before do
        repository.update_attributes!(active: true)
        gh["/repositories/#{repository.github_id}/hooks"] = [INACTIVE_HOOK]
      end

      it 'marks repository as inactive' do
        run.should change { repository.reload.active }
        repository.active.should be_false
      end
    end
  end
end
