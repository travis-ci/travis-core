require 'spec_helper'
require 'support/active_record'

describe Build, 'matrix' do
  include Support::ActiveRecord

  before { Build.send :public, :matrix_config, :expand_matrix_config }
  after  { Build.send :protected, :matrix_config, :expand_matrix_config }

  describe :matrix_finished? do
    context "if at least one job has not finished" do
      it 'returns false' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
        build.matrix[0].update_attributes(:state => :finished)
        build.matrix[1].update_attributes(:state => :started)

        build.matrix_finished?.should_not be_true
      end
    end

    context "if all jobs have finished" do
      it 'returns true' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
        build.matrix[0].update_attributes!(:state => :finished)
        build.matrix[1].update_attributes!(:state => :finished)

        build.matrix_finished?.should_not be_nil
      end
    end
  end

  describe :matrix_status do
    context "if any job has the status 1" do
      it 'returns 1 ' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
        build.matrix[0].update_attributes!(:status => 1, :state => :finished)
        build.matrix[1].update_attributes!(:status => 0, :state => :finished)
        build.matrix_status.should == 1
      end
    end

    context "if all jobs have the status 0" do
      it 'returns 0' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
        build.matrix[0].update_attributes!(:status => 0, :state => :finished)
        build.matrix[1].update_attributes!(:status => 0, :state => :finished)
        build.matrix_status.should == 0
      end
    end

    context "if a failed job is allowed to fail" do
      it 'returns 0' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
        build.matrix[0].update_attributes!(:status => 0, :state => :finished)
        build.matrix[1].update_attributes!(:status => 1, :state => :finished, :allow_failure => true)
        build.matrix_status.should == 0
      end
    end

    it 'returns 1 if all jobs fail and one is allowed to fail' do
      build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] })
      build.matrix[0].update_attributes!(:status => 1, :state => :finished)
      build.matrix[1].update_attributes!(:status => 1, :state => :finished, :allow_failure => true)
      build.matrix_status.should == 1
    end
  end

  describe :matrix_duration do
    let(:build) do
      Build.new(:matrix => [
                            Job::Test.new(:started_at => 60.seconds.ago, :finished_at => 40.seconds.ago),
                            Job::Test.new(:started_at => 20.seconds.ago, :finished_at => 10.seconds.ago)
                           ])
    end

    context "if the matrix is finished" do
      it 'returns the sum of the matrix job durations' do
        build.stubs(:matrix_finished?).returns(true)
        build.matrix_duration.should == 30
      end
    end

    context "if the matrix is not finished" do
      it 'returns nil' do
        build.stubs(:matrix_finished?).returns(false)
        build.matrix_duration.should be_nil
      end
    end
  end

  describe :matrix_config do
    describe "for Ruby projects" do
      it 'with string values' do
        build = Factory(:build, :config => { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-2.3.x', :env => 'FOO=bar' })
        expected = [
                    [[:rvm,     '1.8.7']],
                    [[:gemfile, 'gemfiles/rails-2.3.x']],
                    [[:env,     'FOO=bar']]
                   ]
        build.matrix_config.should == expected
      end

      it 'with two Rubies and Gemfiles' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'], :gemfile => ['gemfiles/rails-2.3.x', 'gemfiles/rails-3.0.x'] })
        expected = [
                    [[:rvm, '1.8.7'], [:rvm, '1.9.2']],
                    [[:gemfile, 'gemfiles/rails-2.3.x'], [:gemfile, 'gemfiles/rails-3.0.x']]
                   ]
        build.matrix_config.should == expected
      end

      it 'with unequal number of Rubies, env variables and Gemfiles' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2', 'ree'], :gemfile => ['gemfiles/rails-3.0.x'], :env => ['DB=postgresql', 'DB=mysql'] })
        build.matrix_config.should == [
                                       [[:rvm, '1.8.7'], [:rvm, '1.9.2'], [:rvm, 'ree']],
                                       [[:gemfile, 'gemfiles/rails-3.0.x'], [:gemfile, 'gemfiles/rails-3.0.x'], [:gemfile, 'gemfiles/rails-3.0.x']],
                                       [[:env, 'DB=postgresql'], [:env, 'DB=mysql'], [:env, 'DB=mysql']]
                                      ]
      end

      it 'with an array of Rubies and a single Gemfile' do
        build = Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'], :gemfile => 'gemfiles/rails-2.3.x' })
        build.matrix_config.should == [
                                       [[:rvm, '1.8.7'], [:rvm, '1.9.2']],
                                       [[:gemfile, 'gemfiles/rails-2.3.x'], [:gemfile, 'gemfiles/rails-2.3.x']]
                                      ]
      end
    end


    describe "for Scala projects" do
      it 'with a single Scala version given as a string' do
        build = Factory(:build, :config => { :scala => '2.8.2', :env => 'NETWORK=false' })
        expected = [
                    [[:env, 'NETWORK=false']],
                    [[:scala, '2.8.2']]
                   ]
        build.matrix_config.should == expected
      end

      it 'with multiple Scala versions and no env variables' do
        build = Factory(:build, :config => { :scala => ['2.8.2', '2.9.1']})
        expected = [
                    [[:scala, '2.8.2'], [:scala, '2.9.1']]
                   ]
        build.matrix_config.should == expected
      end

      it 'with a single Scala version passed in as array and two env variables' do
        build = Factory(:build, :config => { :scala => ['2.8.2'], :env => ['STORE=postgresql', 'STORE=redis'] })
        build.matrix_config.should == [
                                       [[:env, 'STORE=postgresql'], [:env, 'STORE=redis']],
                                       [[:scala, '2.8.2'], [:scala, '2.8.2']]
                                      ]
      end
    end
  end

  let(:no_matrix_config) {
    YAML.load <<-yml
      script: "rake ci"
    yml
  }

  let(:single_test_config) {
    YAML.load <<-yml
      script: "rake ci"
      rvm:
        - 1.8.7
      gemfile:
        - gemfiles/rails-3.0.6
      env:
        - USE_GIT_REPOS=true
    yml
  }

  let(:multiple_tests_config) {
    YAML.load <<-yml
      script: "rake ci"
      rvm:
        - 1.8.7
        - 1.9.1
        - 1.9.2
      gemfile:
        - gemfiles/rails-3.0.6
        - gemfiles/rails-3.0.7
        - gemfiles/rails-3-0-stable
        - gemfiles/rails-master
      env:
        - USE_GIT_REPOS=true
    yml
  }

  let(:multiple_tests_config_with_exculsion) {
    YAML.load <<-yml
      rvm:
        - 1.8.7
        - 1.9.2
      gemfile:
        - gemfiles/rails-2.3.x
        - gemfiles/rails-3.0.x
        - gemfiles/rails-3.1.x
      matrix:
        exclude:
          - rvm: 1.8.7
            gemfile: gemfiles/rails-3.1.x
          - rvm: 1.9.2
            gemfile: gemfiles/rails-2.3.x
    yml
  }

  let(:multiple_tests_config_with_invalid_exculsion) {
    YAML.load <<-yml
      rvm:
        - 1.8.7
        - 1.9.2
      gemfile:
        - gemfiles/rails-3.0.x
        - gemfiles/rails-3.1.x
      env:
        - FOO=bar
        - BAR=baz
      matrix:
        exclude:
          - rvm: 1.9.2
            gemfile: gemfiles/rails-3.0.x
    yml
  }

  let(:multiple_tests_config_with_allow_failures) {
    YAML.load <<-yml
      rvm:
        - 1.8.7
        - 1.9.2
      gemfile:
        - gemfiles/rails-2.3.x
        - gemfiles/rails-3.0.x
        - gemfiles/rails-3.1.x
      matrix:
        allow_failures:
          - rvm: 1.9.2
            gemfile: gemfiles/rails-2.3.x
    yml
  }

  describe :expand_matrix_config do
    it 'expands the build matrix configuration (single test config)' do
      build = Factory(:build, :config => single_test_config)
      build.expand_matrix_config(build.matrix_config.to_a).should == [
                                                                      [[:rvm, '1.8.7'], [:gemfile, 'gemfiles/rails-3.0.6'],      [:env, 'USE_GIT_REPOS=true']],
                                                                     ]
    end

    it 'expands the build matrix configuration (multiple tests config)' do
      build = Factory(:build, :config => multiple_tests_config)
      build.expand_matrix_config(build.matrix_config.to_a).should == [
                                                                      [[:rvm, '1.8.7'], [:gemfile, 'gemfiles/rails-3.0.6'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.8.7'], [:gemfile, 'gemfiles/rails-3.0.7'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.8.7'], [:gemfile, 'gemfiles/rails-3-0-stable'], [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.8.7'], [:gemfile, 'gemfiles/rails-master'],     [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.1'], [:gemfile, 'gemfiles/rails-3.0.6'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.1'], [:gemfile, 'gemfiles/rails-3.0.7'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.1'], [:gemfile, 'gemfiles/rails-3-0-stable'], [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.1'], [:gemfile, 'gemfiles/rails-master'],     [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-3.0.6'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-3.0.7'],      [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-3-0-stable'], [:env, 'USE_GIT_REPOS=true']],
                                                                      [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-master'],     [:env, 'USE_GIT_REPOS=true']]
                                                                     ]
    end
  end

  describe :expand_matrix do
    it 'sets the config to the jobs (no config)' do
      build = Factory(:build, :config => {})
      build.matrix.map(&:config).should == [{}]
    end

    it 'sets the config to the jobs (no matrix config)' do
      build = Factory(:build, :config => no_matrix_config)
      build.matrix.map(&:config).should == [{ :script => 'rake ci' }]
    end

    it 'sets the config to the jobs (single test config)' do
      build = Factory(:build, :config => single_test_config)
      build.matrix.map(&:config).should == [
                                            { :script => 'rake ci', :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.6', :env => 'USE_GIT_REPOS=true' }
                                           ]
    end

    it 'sets the config to the jobs (multiple tests config)' do
      build = Factory(:build, :config => multiple_tests_config)
      build.matrix.map(&:config).should == [
                                            { :script => 'rake ci', :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.6',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.7',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3-0-stable', :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.8.7', :gemfile => 'gemfiles/rails-master',     :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.1', :gemfile => 'gemfiles/rails-3.0.6',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.1', :gemfile => 'gemfiles/rails-3.0.7',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.1', :gemfile => 'gemfiles/rails-3-0-stable', :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.1', :gemfile => 'gemfiles/rails-master',     :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.0.6',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.0.7',      :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3-0-stable', :env => 'USE_GIT_REPOS=true' },
                                            { :script => 'rake ci', :rvm => '1.9.2', :gemfile => 'gemfiles/rails-master',     :env => 'USE_GIT_REPOS=true' }
                                           ]
    end

    it 'sets the config to the jobs (allow failures config)' do
      build = Factory(:build, :config => multiple_tests_config_with_allow_failures)
      build.matrix.map(&:allow_failure).should == [false, false, false, true, false, false]
    end

    it 'copies build attributes' do
      # TODO spec other attributes!
      build = Factory(:build, :config => multiple_tests_config)
      build.matrix.map(&:commit_id).uniq.should == [build.commit_id]
    end

    it 'adds a sub-build number to the job number' do
      build = Factory(:build, :config => multiple_tests_config)
      build.matrix.map(&:number)[0..3].should == ['1.1', '1.2', '1.3', '1.4']
    end

    describe :exclude_matrix_config do
      it 'excludes a matrix config when all config items are defined in the exclusion' do
        build = Factory(:build, :config => multiple_tests_config_with_exculsion)

        matrix_exclusion = {
          :exclude => [
                       { :rvm => "1.8.7", :gemfile => "gemfiles/rails-3.1.x" },
                       { :rvm => "1.9.2", :gemfile => "gemfiles/rails-2.3.x" }
                      ]
        }

        build.matrix.map(&:config).should == [
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-2.3.x', :matrix => matrix_exclusion },
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.x', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.0.x', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.1.x', :matrix => matrix_exclusion }
                                             ]
      end

      it 'does not exclude a matrix config when the matrix exclusion definition is incomplete' do
        build = Factory(:build, :config => multiple_tests_config_with_invalid_exculsion)

        matrix_exclusion = { :exclude => [{ :rvm => "1.9.2", :gemfile => "gemfiles/rails-3.0.x" }] }

        build.matrix.map(&:config).should == [
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.x', :env => 'FOO=bar', :matrix => matrix_exclusion },
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.0.x', :env => 'BAR=baz', :matrix => matrix_exclusion },
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.1.x', :env => 'FOO=bar', :matrix => matrix_exclusion },
                                              { :rvm => '1.8.7', :gemfile => 'gemfiles/rails-3.1.x', :env => 'BAR=baz', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.0.x', :env => 'FOO=bar', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.0.x', :env => 'BAR=baz', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.1.x', :env => 'FOO=bar', :matrix => matrix_exclusion },
                                              { :rvm => '1.9.2', :gemfile => 'gemfiles/rails-3.1.x', :env => 'BAR=baz', :matrix => matrix_exclusion }
                                             ]
      end
    end
  end

  describe 'matrix_for' do
    it 'selects matching builds' do
      build = Factory(:build, :config => { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => '1.8.7', 'env' => 'DB=sqlite3' }).should == [build.matrix[0]]
    end

    it 'does not select builds with non-matching values' do
      build = Factory(:build, :config => { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => 'nomatch', 'env' => 'DB=sqlite3' }).should be_empty
    end

    it 'does not select builds with non-matching keys' do
      build = Factory(:build, :config => { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => '1.8.7', 'nomatch' => 'DB=sqlite3' }).should == [build.matrix[0], build.matrix[1]]
    end
  end

  describe 'matrix_keys_for' do
    it 'only selects ENV_KEYS' do
      Build::Matrix::ENV_KEYS.each do |key|
        Build.matrix_keys_for('invalid key' => 'invalid', key => 'valid').should == [key]
      end
    end

    it 'selects symbolized ENV_KEYS' do
      Build::Matrix::ENV_KEYS.each do |key|
        Build.matrix_keys_for(key => 'valid').should == [key]
      end
    end
  end
end
