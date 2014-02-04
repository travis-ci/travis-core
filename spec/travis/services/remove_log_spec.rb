require 'spec_helper'

describe Travis::Services::RemoveLog do
  include Support::ActiveRecord
  include Travis::Testing::Stubs

  let(:repo)    { Factory(:repository) }
  let(:job)     { Factory(:test, repository: repo, state: :created) }
  let(:user)    { Factory(:user) }
  let(:service) { described_class.new(user, params) }
  let(:params)  { { id: job.id, reason: 'Because reason!'} }

  context 'when job is not finished' do
    before :each do
      job.stubs(:finished?).returns false
      user.stubs(:permission?).with(:push, anything).returns true
    end

    it 'does not change log' do
      expect {
        service.run
      }.to_not change { service.log.reload.content }
    end
  end

  context 'when user does not have push permissions' do
    before :each do
      user.stubs(:permission?).with(:push, anything).returns false
    end

    it 'does not change log' do
      expect {
        service.run
      }.to_not change { service.log.reload.content }
    end
  end

  context 'when a job is found' do
    before :all do
      find_by_id = stub
      find_by_id.stubs(:find_by_id).returns job
      job.stubs(:finished?).returns true
      service.stubs(:scope).returns find_by_id
      user.stubs(:permission?).with(:push, anything).returns true
    end

    before :each do
      @result = service.run
    end

    it 'runs successfully' do
      @result.should be_true
    end


    it "updates logs with desired information" do
      service.log.content.should =~ Regexp.new(user.name)
      service.log.content.should =~ Regexp.new(params[:reason])
    end
  end

  context 'when a job is not found' do
    before :all do
      find_by_id = stub
      find_by_id.stubs(:find_by_id).raises(ActiveRecord::SubclassNotFound)
      service.stubs(:scope).returns(find_by_id)
    end

    it 'raises ActiveRecord::RecordNotFound exception' do
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
