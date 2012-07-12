require 'spec_helper'

class Build
  module Matrix
    describe Config do
      it 'can handle nil values in exclude matrix' do
        build = stub("Build", :config => nil)
        config = Config.new(build)
        config.expects(:matrix_settings).returns(:exclude => [nil])
        config.exclude_config?({})
      end
    end
  end
end
