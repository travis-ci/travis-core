require 'spec_helper'

describe Travis::CommitCommand do
  describe 'skip' do
    it 'is not invoked by default' do
      message = "initial commit"
      Travis::CommitCommand.new(message).skip?.should eq false
    end

    it 'is invoked by a commit message containing [ci skip]' do
      message = "foo [ci skip] bar"
      Travis::CommitCommand.new(message).skip?.should eq true
    end

    it 'is invoked by a commit message containing [ci build]' do
      message = "foo [ci build] bar"
      Travis::CommitCommand.new(message).build?.should eq true
    end

    it 'is invoked by a commit message containing [CI skip]' do
      message = "foo [CI skip] bar"
      Travis::CommitCommand.new(message).skip?.should eq true
    end

    it 'is invoked by a commit message containing [ci:skip]' do
      message = "foo [ci:skip] bar"
      Travis::CommitCommand.new(message).skip?.should eq true
    end

    it 'is not invoked by a commit message containing [ci unknown-command]' do
      message = "foo [ci unknown-command] bar"
      Travis::CommitCommand.new(message).skip?.should eq false
    end

    it 'is invoked by the special case: [skip ci]' do
      message = "foo [skip ci] bar"
      Travis::CommitCommand.new(message).skip?.should eq true
    end
  end
end
