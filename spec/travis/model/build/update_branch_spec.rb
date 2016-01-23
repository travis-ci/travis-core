require 'spec_helper'

describe Build::UpdateBranch do
  include Support::ActiveRecord

  let(:build)  { Factory.build(:build, state: :started, duration: 30, branch: 'master') }
  let(:branch) { Branch.where(repository_id: build.repository_id, name: build.branch).first }

  subject { described_class.new(build) }

  describe 'on build creation' do
    describe 'creates branch if missing' do
      before { build.save }
      it { branch.should_not be_nil }
      it { branch.last_build_id.should be == build.id }
    end

    describe 'updates an existing branch' do
      before { Branch.create!(repository_id: build.repository_id, name: 'master') }
      before { build.save }
      it { branch.should_not be_nil }
      it { branch.last_build_id.should be == build.id }
    end
  end
end

