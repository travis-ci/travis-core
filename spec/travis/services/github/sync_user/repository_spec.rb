require 'spec_helper'

describe Travis::Services::Github::SyncUser::Repository do
  include Support::ActiveRecord

  let(:subject) { Travis::Services::Github::SyncUser::Repository }
  let(:user)    { Factory(:user) }
  let(:run)     { lambda { subject.new(user, repo).run } }

  describe 'find or create repository' do
    let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => false, 'push' => false, 'pull' => true } } }

    it 'creates a new repository per record if not yet present' do
      run.call
      Repository.find_by_owner_name_and_name('sven', 'minimal').should be_present
    end

    it 'does not create a new repository' do
      Repository.create!(:owner_name => 'sven', :name => 'minimal')
      run.should_not change(Repository, :count)
    end
  end

  describe 'a public repository' do
    describe 'only pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => false, 'push' => false, 'pull' => true } } }

      it "doesn't create a new permission for the user/repo" do
        run.should_not change(Permission, :count)
      end

      it "destroys an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :push => true, :pull => true)
        run.should change(Permission, :count).by(-1)
      end
    end

    describe 'push and pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => false, 'push' => true, 'pull' => true } } }

      it "creates a new permission for the user/repo" do
        run.should change(Permission, :count).by(1)
      end

      it "updates an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :admin => true, :push => true, :pull => true)

        run.should_not change(Permission, :count)

        permission = Permission.first
        permission.admin.should == false
        permission.push.should == true
        permission.pull.should == true
      end
    end

    describe 'admin, push and pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true, 'push' => true, 'pull' => true } } }

      it "creates a new permission for the user/repo" do
        run.should change(Permission, :count).by(1)
      end

      it "updates an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :push => true, :pull => true)

        run.should_not change(Permission, :count)

        permission = Permission.first
        permission.admin.should == true
        permission.push.should == true
        permission.pull.should == true
      end
    end
  end

  describe 'a private repository' do
    describe 'only pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'private' => true, 'permissions' => { 'admin' => false, 'push' => false, 'pull' => true } } }

      it "creates a new permission for the user/repo" do
        run.should change(Permission, :count)
      end

      it "updates an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :admin => true, :push => true, :pull => true)

        run.should_not change(Permission, :count)

        permission = Permission.first
        permission.admin.should == false
        permission.push.should == false
        permission.pull.should == true
      end
    end

    describe 'push and pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'private' => true, 'permissions' => { 'admin' => false, 'push' => true, 'pull' => true } } }

      it "creates a new permission for the user/repo" do
        run.should change(Permission, :count).by(1)
      end

      it "updates an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :admin => true, :push => true, :pull => true)

        run.should_not change(Permission, :count)

        permission = Permission.first
        permission.admin.should == false
        permission.push.should == true
        permission.pull.should == true
      end
    end

    describe 'admin, push and pull access' do
      let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'private' => true, 'permissions' => { 'admin' => true, 'push' => true, 'pull' => true } } }

      it "creates a new permission for the user/repo" do
        run.should change(Permission, :count).by(1)
      end

      it "updates an existing permission" do
        repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
        repo.permissions.create(:user => user, :push => true, :pull => true)

        run.should_not change(Permission, :count)

        permission = Permission.first
        permission.admin.should == true
        permission.push.should == true
        permission.pull.should == true
      end
    end
  end
end
