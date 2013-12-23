require 'spec_helper'
require 'core_ext/hash/deep_symbolize_keys'

class Build
  module Matrix
    describe Config do
      include Support::ActiveRecord

      it 'can handle nil values in exclude matrix' do
        -> { Config.new(matrix: { exclude: [nil] }).expand }.should_not raise_error
      end

    end
  end
end
