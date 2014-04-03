require 'spec_helper'

describe Travis::Github::Services::SyncUser::Hooks do
  include Support::ActiveRecord

  ACTIVE_HOOK = { 'name' => 'travis', 'config' => { 'domain' => '' }, 'active' => true }
  INACTIVE_HOOK = { 'name' => 'travis', 'config' => { 'domain' => '' }, 'active' => false }

  let(:user) { Factory(:user) }
  let(:repository) { Factory(:repository) }
  let(:gh) { Hash.new }
  let(:run) { -> { described_class.new(user, false, gh).run } }

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

    context 'hook was synced < 24 hours ago' do
      before do
        repository.update_attributes!(last_sync: Time.now)
      end

      it 'doesn\'t sync' do
        repository.update_attributes!(active: false)
        gh["/repositories/#{repository.github_id}/hooks"] = [ACTIVE_HOOK]

        run.should_not change { repository.reload.active }
      end

      context 'for a forced sync' do
        it 'does sync' do
          repository.update_attributes!(active: false)
          gh["/repositories/#{repository.github_id}/hooks"] = [ACTIVE_HOOK]

          expect { described_class.new(user, true, gh).run }
            .to change { repository.reload.active }
            .from(false).to(true)
        end
      end
    end
  end
end
