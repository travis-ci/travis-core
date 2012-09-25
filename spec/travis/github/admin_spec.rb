require 'spec_helper'

describe Travis::Github::Admin do
  include Travis::Testing::Stubs

  describe 'find' do
    before :each do
      User.stubs(:with_permissions).with(:repository_id => repository.id, :admin => true).returns [user]
    end

    subject { Travis::Github::Admin.new(repository).find }

    def ignore_exception(&block)
      block.call
    rescue Travis::AdminMissing
    end

    describe 'given a user has admin access to a repository (as seen by github)' do
      before :each do
        GH.stubs(:[]).with("repos/#{repository.slug}").returns('permissions' => { 'admin' => true })
      end

      it 'returns that user' do
        subject.should == user
      end
    end

    describe 'given a user does not have access to a repository' do
      before :each do
        GH.stubs(:[]).with("repos/#{repository.slug}").returns('permissions' => { 'admin' => false })
        user.stubs(:update_attributes!)
      end

      it 'raises an exception' do
        lambda { subject }.should raise_error(Travis::AdminMissing, 'no admin available for svenfuchs/minimal')
      end

      it 'revokes admin permissions for that user on our side' do
        user.expects(:update_attributes!).with(:permissions => { 'admin' => false })
        ignore_exception { subject }
      end
    end

    describe 'given an error occurs while retrieving the repository info' do
      let(:error) { stub('error', :backtrace => [], :response => stub('reponse')) }

      before :each do
        GH.stubs(:[]).with("repos/#{repository.slug}").raises(GH::Error.new(error))
      end

      it 'raises an exception' do
        lambda { subject }.should raise_error(Travis::AdminMissing, 'no admin available for svenfuchs/minimal')
      end

      it 'does not revoke permissions' do
        user.expects(:update_permissions!).never
        ignore_exception { subject }
      end
    end
  end
end
