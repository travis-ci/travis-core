require 'spec_helper'

class Build
  module Matrix
    describe Config do
      include Support::ActiveRecord

      let(:matrix_with_os_ruby) {
        YAML.load <<-yml
        language: ruby
        os:
          - osx
          - linux
        rvm:
          - 2.0.0
          - 1.9.3
        gemfile:
          - 'gemfiles/rails-4'
      yml
      }

      it 'can handle nil values in exclude matrix' do
        build = stub("Build", :config => nil)
        config = Config.new(build)
        config.expects(:matrix_settings).returns(:exclude => [nil])
        config.exclude_config?({})
      end

      context 'multi_os feature is active for all repos' do
        before :each do
          repo    = Factory(:repository)
          request = Factory(:request, repository: repo)
          build   = Factory(:build, config: matrix_with_os_ruby, request: request)
          Travis::Features.stubs(:enabled_for_all?).with(:multi_os).returns(true)
          @config = Config.new(build)
        end

        it 'expands on :os' do
          @config.expand.should == [
            [[:os, 'osx'], [:rvm, '2.0.0'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'osx'], [:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'linux'], [:rvm, '2.0.0'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'linux'], [:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4']]
          ]
        end
      end

      context 'multi_os feature is active for one repo' do
        before :each do
          repo    = Factory(:repository)
          request = Factory(:request, repository: repo)
          build   = Factory(:build, config: matrix_with_os_ruby, request: request)
          Travis::Features.stubs(:enabled_for_all?).with(:multi_os).returns(false)
          Travis::Features.stubs(:active?).with(:multi_os, repo).returns(true)
          @config = Config.new(build)
        end

        it 'expands on :os' do
          @config.expand.should == [
            [[:os, 'osx'], [:rvm, '2.0.0'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'osx'], [:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'linux'], [:rvm, '2.0.0'], [:gemfile, 'gemfiles/rails-4']],
            [[:os, 'linux'], [:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4']]
          ]
        end
      end

      context 'multi_os feature is inactive' do
        before :each do
          repo    = Factory(:repository)
          request = Factory(:request, repository: repo)
          build   = Factory(:build, config: matrix_with_os_ruby, request: request)
          Travis::Features.stubs(:enabled_for_all?).with(:multi_os).returns(false)
          Travis::Features.stubs(:active?).with(:multi_os, repo).returns(false)
          @config = Config.new(build)
        end

        it 'does not expand on :os' do
          @config.expand.should == [
            [[:rvm, '2.0.0'], [:gemfile, 'gemfiles/rails-4']],
            [[:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4']],
          ]
        end
      end
    end
  end
end
