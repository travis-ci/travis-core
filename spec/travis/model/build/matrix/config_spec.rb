require 'spec_helper'
require 'core_ext/hash/deep_symbolize_keys'

class Build
  module Matrix
    describe Config do
      include Support::ActiveRecord

      let(:matrix_with_os_ruby) {
        YAML.load(%(
          language: ruby
          os:
            - osx
            - linux
          rvm:
            - 2.0.0
            - 1.9.3
          gemfile:
            - 'gemfiles/rails-4'
        )).deep_symbolize_keys
      }

      it 'can handle nil values in exclude matrix' do
        -> { Config.new(matrix: { exclude: [nil] }).expand }.should_not raise_error
      end

      context 'multi_os feature is active' do
        it 'expands on :os' do
          config = Config.new(matrix_with_os_ruby, multi_os: true)
          config.expand.should == [
            { language: 'ruby', os: 'osx',   rvm: '2.0.0', gemfile: 'gemfiles/rails-4' },
            { language: 'ruby', os: 'linux', rvm: '2.0.0', gemfile: 'gemfiles/rails-4' },
            { language: 'ruby', os: 'osx',   rvm: '1.9.3', gemfile: 'gemfiles/rails-4' },
            { language: 'ruby', os: 'linux', rvm: '1.9.3', gemfile: 'gemfiles/rails-4' }
          ]
        end
      end

      context 'multi_os feature is inactive' do
        it 'does not expand on :os' do
          config = Config.new(matrix_with_os_ruby)
          config.expand.should == [
            { language: 'ruby', rvm: '2.0.0', gemfile: 'gemfiles/rails-4' },
            { language: 'ruby', rvm: '1.9.3', gemfile: 'gemfiles/rails-4' }
          ]
        end
      end
    end
  end
end
