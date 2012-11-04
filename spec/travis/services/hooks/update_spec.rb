require 'spec_helper'

describe Travis::Services::Hooks::Update do
  include Travis::Testing::Stubs

  let(:service) { Travis::Services::Hooks::Update.new(user, params) }
  let(:params)  { { id: repo.id, active: true } }

  before :each do
    repo.stubs(:update_column)
    service.stubs(:service).returns(stub(run: repo))
  end

  it 'finds the repo by the given id' do
    service.expects(:service).with(:hooks, :find_one, params).returns(stub(run: repo))
    service.run
  end

  it 'sets the given :active param to the hook' do
    service.expects(:service).with(:github, :set_hook, params).returns(stub(run: nil))
    service.run
  end

  describe 'sets the repo to the active param' do
    it 'given true' do
      service.params.update(active: true)
      repo.expects(:update_column).with(:active, true)
      service.run
    end

    it 'given false' do
      service.params.update(active: false)
      repo.expects(:update_column).with(:active, false)
      service.run
    end

    it 'given "true"' do
      service.params.update(active: 'true')
      repo.expects(:update_column).with(:active, true)
      service.run
    end

    it 'given "false"' do
      service.params.update(active: 'false')
      repo.expects(:update_column).with(:active, false)
      service.run
    end
  end
end
