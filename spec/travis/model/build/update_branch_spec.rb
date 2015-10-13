require 'spec_helper'

describe Build, 'update_branch' do
  include Support::ActiveRecord

  let(:build) { Factory(:build, state: :started, duration: 30, branch: 'master') }

  describe 'on build:started' do
    it 'creates branch if branch is missing' do
      Branch.fetch(build.repository, 'master').destroy
      Branch.where(repository_id: build.repository_id, name: build.branch).should_not be_any

      build.update_branch

      branch = Branch.where(repository_id: build.repository_id, name: build.branch).first
      branch.should_not be_nil
      branch.last_build.should be == build
    end

    it 'updates branch if branch is exists' do
      Branch.fetch(build.repository, 'master')

      build.update_branch

      branch = Branch.fetch(build.repository, 'master')
      branch.last_build.should be == build
    end
  end

  describe 'on build:finished' do
    it 'creates branch if branch is missing' do
      Branch.fetch(build.repository, 'master').destroy
      Branch.where(repository_id: build.repository_id, name: build.branch).should_not be_any

      build.update_branch

      branch = Branch.where(repository_id: build.repository_id, name: build.branch).first
      branch.should_not be_nil
      branch.last_build.should be == build
    end

    it 'updates branch if branch is exists' do
      Branch.fetch(build.repository, 'master')

      build.update_branch

      branch = Branch.fetch(build.repository, 'master')
      branch.last_build.should be == build
    end
  end
end

