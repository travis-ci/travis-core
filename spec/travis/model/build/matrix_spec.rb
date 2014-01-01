require 'spec_helper'

describe Build, 'matrix' do
  include Support::ActiveRecord

  before { Build.send :public,    :matrix_config }
  after  { Build.send :protected, :matrix_config }

  describe :matrix_finished? do
    context 'if config[:matrix][:finish_fast] is not set' do
      context 'if at least one job has not finished and is not allowed to fail' do
        it 'returns false' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'] })
          build.matrix[0].update_attributes(state: :passed)
          build.matrix[1].update_attributes(state: :started)

          build.matrix_finished?.should_not be_true
        end
      end

      context 'if at least one job has not finished and is allowed to fail' do
        it 'returns false' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'] })
          build.matrix[0].update_attributes(state: :passed)
          build.matrix[1].update_attributes(state: :started, allow_failure: true)

          build.matrix_finished?.should_not be_true
        end
      end

      context 'if all jobs have finished' do
        it 'returns true' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'] })
          build.matrix[0].update_attributes!(state: :passed)
          build.matrix[1].update_attributes!(state: :passed)

          build.matrix_finished?.should be_true
        end
      end
    end
    context 'if config[:matrix][:finish_fast] is set' do
      context 'if at least one job has not finished and is not allowed to fail' do
        it 'returns false' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'], matrix: {fast_finish: true} })
          build.matrix[0].update_attributes(state: :passed)
          build.matrix[1].update_attributes(state: :started)

          build.matrix_finished?.should be_false
        end
      end

      context 'if at least one job has not finished and is allowed to fail' do
        it 'returns true' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'], matrix: {fast_finish: true} })
          build.matrix[0].update_attributes(state: :passed)
          build.matrix[1].update_attributes(state: :started, allow_failure: true)

          build.matrix_finished?.should be_true
        end
      end

      context 'if all jobs have finished' do
        it 'returns true' do
          build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'], matrix: {fast_finish: true} })
          build.matrix[0].update_attributes!(state: :passed)
          build.matrix[1].update_attributes!(state: :passed)

          build.matrix_finished?.should be_true
        end
      end
    end
  end

  describe :matrix_state do
    let(:build) { Factory(:build, config: { rvm: ['1.8.7', '1.9.2'] }) }

    it 'returns :passed if all jobs have passed' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "passed")
      build.matrix_state.should == :passed
    end

    it 'returns :failed if one job has failed' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "failed")
      build.matrix_state.should == :failed
    end

    it 'returns :failed if one job has failed and one job has errored' do
      build.matrix[0].update_attributes!(state: "errored")
      build.matrix[1].update_attributes!(state: "failed")
      build.matrix_state.should == :errored
    end

    it 'returns :errored if one job has errored' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "errored")
      build.matrix_state.should == :errored
    end

    it 'returns :created if one job has been created' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "created")
      build.matrix_state.should == :created
    end

    it 'returns :created if one job has been created, and the other been queued' do
      build.matrix[0].update_attributes!(state: "queued")
      build.matrix[1].update_attributes!(state: "created")
      build.matrix_state.should == :created
    end

    it 'returns :queued if one job has been queued' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "queued")
      build.matrix_state.should == :queued
    end

    it 'returns :queued if one job has been queued, and the other started' do
      build.matrix[0].update_attributes!(state: "started")
      build.matrix[1].update_attributes!(state: "queued")
      build.matrix_state.should == :queued
    end

    it 'returns :started if one job has started' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "started")
      build.matrix_state.should == :started
    end

    it 'returns :passed if a errored job is allowed to fail' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "errored", allow_failure: true)
      build.matrix_state.should == :passed
    end

    it 'returns :passed if a failed job is allowed to fail' do
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "failed", allow_failure: true)
      build.matrix_state.should == :passed
    end

    it 'returns :failed if all jobs have failed and only one is allowed to fail' do
      build.matrix[0].update_attributes!(state: "failed")
      build.matrix[1].update_attributes!(state: "failed", allow_failure: true)
      build.matrix_state.should == :failed
    end

    it 'returns :failed if all jobs have failed and only one is allowed to fail' do
      build.matrix[0].update_attributes!(state: "finished")
      expect { build.matrix_state }.to raise_error(StandardError)
    end

    it 'returns :passed if all jobs have passed except a job that is allowed to fail, and config[:matrix][:finish_fast] is set' do
      build.config.update(finish_fast: true)
      build.matrix[0].update_attributes!(state: "passed")
      build.matrix[1].update_attributes!(state: "failed", allow_failure: true)
      build.matrix_state.should == :passed
    end
  end

  context 'matrix with one allow_failure job' do
    let(:build) { Factory(:build, config: { rvm: ['1.9.3'] }) }

    it 'returns :passed' do
      build.matrix[0].update_attributes!(state: "failed", allow_failure: true)
      build.matrix_state.should == :passed
    end
  end

  describe :matrix_duration do
    let(:build) do
      Build.new(matrix: [
        Job::Test.new(started_at: 60.seconds.ago, finished_at: 40.seconds.ago),
        Job::Test.new(started_at: 20.seconds.ago, finished_at: 10.seconds.ago)
       ])
    end

    context 'if the matrix is finished' do
      it 'returns the sum of the matrix job durations' do
        build.stubs(:matrix_finished?).returns(true)
        build.matrix_duration.should == 30
      end
    end

    context 'if the matrix is not finished' do
      it 'returns nil' do
        build.stubs(:matrix_finished?).returns(false)
        build.matrix_duration.should be_nil
      end
    end
  end

  describe 'for Ruby projects' do
    let(:no_matrix_config) {
      YAML.load <<-yml
      script: 'rake ci'
    yml
    }

    let(:single_test_config) {
      YAML.load <<-yml
      script: 'rake ci'
      rvm:
        - 1.8.7
      gemfile:
        - gemfiles/rails-3.0.6
      env:
        - USE_GIT_REPOS=true
    yml
    }

    let(:env_global_config) {
      YAML.load <<-yml
      script: 'rake ci'
      rvm:
        - 1.9.2
        - 1.9.3
      gemfile:
        - gemfiles/rails-4.0.0
      env:
        global:
          - TOKEN=abcdef
        matrix:
          - FOO=bar
          - BAR=baz
    yml
    }

    let(:multiple_tests_config) {
      YAML.load <<-yml
      script: 'rake ci'
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

    let(:multiple_tests_config_with_global_env_and_exclusion) {
      YAML.load <<-yml
      rvm:
        - 1.9.2
        - 2.0.0
      gemfile:
        - gemfiles/rails-3.1.x
        - gemfiles/rails-4.0.x
      env:
        global:
          - FOO=bar
      matrix:
        exclude:
          - rvm: 1.9.2
            gemfile: gemfiles/rails-4.0.x
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

    let(:multiple_tests_config_with_inclusion) {
      YAML.load <<-yml
      rvm:
        - 1.8.7
        - 1.9.2
      env:
        - FOO=bar
        - BAR=baz
      matrix:
        include:
          - rvm: 1.9.2
            env: BAR=xyzzy
    yml
    }

    let(:multiple_tests_config_with_allow_failures) {
      YAML.load <<-yml
      language: objective-c
      rvm:
        - 1.8.7
        - 1.9.2
      xcode_sdk:
        - iphonesimulator6.1
        - iphonesimulator7.0
      matrix:
        allow_failures:
          - rvm: 1.8.7
            xcode_sdk: iphonesimulator7.0
    yml
    }

    let(:allow_failures_with_global_env) {
      YAML.load <<-yml
      rvm:
        - 1.9.3
        - 2.0.0
      env:
        global:
          - "GLOBAL=global NEXT_GLOBAL=next"
        matrix:
          - "FOO=bar"
          - "FOO=baz"
      matrix:
        allow_failures:
          - rvm: 1.9.3
            env: "FOO=bar"
    yml
    }

    let(:matrix_with_unwanted_expansion_ruby) {
      YAML.load <<-yml
      language: ruby
      python:
        - 3.3
        - 2.7
      rvm:
        - 2.0.0
        - 1.9.3
      gemfile:
        - 'gemfiles/rails-4'
    yml
    }

    let(:matrix_with_unwanted_expansion_python) {
      YAML.load <<-yml
      language: python
      python:
        - "3.3"
        - "2.7"
      rvm:
        - 2.0.0
        - 1.9.3
      gemfile:
        - 'gemfiles/rails-4'
    yml
    }

    describe :expand_matrix do
      it 'does not add global entries to a matrix, but leaves them in job config' do
        build = Factory(:build, config: env_global_config)

        build.matrix_config.expand.should == [
          [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-4.0.0'], [:env, 'FOO=bar']],
          [[:rvm, '1.9.2'], [:gemfile, 'gemfiles/rails-4.0.0'], [:env, 'BAR=baz']],
          [[:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4.0.0'], [:env, 'FOO=bar']],
          [[:rvm, '1.9.3'], [:gemfile, 'gemfiles/rails-4.0.0'], [:env, 'BAR=baz']]
        ]

        build.matrix.map do |job|
          job.config[:global_env].should == ["TOKEN=abcdef"]
        end
      end

      it 'sets the config to the jobs (no config)' do
        build = Factory(:build, config: {})
        build.matrix.map(&:config).should == [{}]
      end

      it 'sets the config to the jobs (no matrix config)' do
        build = Factory(:build, config: no_matrix_config)
        build.matrix.map(&:config).should == [{ script: 'rake ci' }]
      end

      it 'sets the config to the jobs (single test config)' do
        build = Factory(:build, config: single_test_config)
        build.matrix.map(&:config).should == [
          { script: 'rake ci', rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.6', env: 'USE_GIT_REPOS=true' }
        ]
      end

      it 'sets the config to the jobs (multiple tests config)' do
        build = Factory(:build, config: multiple_tests_config)
        build.matrix.map(&:config).should == [
          { script: 'rake ci', rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.6',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.7',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.8.7', gemfile: 'gemfiles/rails-3-0-stable', env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.8.7', gemfile: 'gemfiles/rails-master',     env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.1', gemfile: 'gemfiles/rails-3.0.6',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.1', gemfile: 'gemfiles/rails-3.0.7',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.1', gemfile: 'gemfiles/rails-3-0-stable', env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.1', gemfile: 'gemfiles/rails-master',     env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.6',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.7',      env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.2', gemfile: 'gemfiles/rails-3-0-stable', env: 'USE_GIT_REPOS=true' },
          { script: 'rake ci', rvm: '1.9.2', gemfile: 'gemfiles/rails-master',     env: 'USE_GIT_REPOS=true' }
        ]
      end

      it 'sets the config to the jobs (allow failures config)' do
        build = Factory(:build, config: multiple_tests_config_with_allow_failures)
        build.matrix.map(&:allow_failure).should == [false, true, false, false]
      end

      it 'ignores global env config when setting allow failures' do
        build = Factory(:build, config: allow_failures_with_global_env)
        build.matrix.map(&:allow_failure).should == [true, false, false, false]
      end

      context 'when ruby project contains unwanted key' do
        before :each do
          @build_ruby = Factory(:build, config: matrix_with_unwanted_expansion_ruby)
        end

        it 'ignores irrelevant matrix dimensions' do
          @build_ruby.matrix_config.expand.should == [
            [[:rvm, "2.0.0"], [:gemfile, "gemfiles/rails-4"]],
            [[:rvm, "1.9.3"], [:gemfile, "gemfiles/rails-4"]]
          ]
        end

        it 'creates jobs whose config does not contain unwanted keys' do
          @build_ruby.expand_matrix.each do |job|
            job.config.keys.should_not include(:python)
          end
        end

        it 'does not touch config' do
          @build_ruby.config.keys.should include(:python)
        end
      end

      context 'when python project contains unwanted key' do
        before :each do
          @build_python = Factory(:build, config: matrix_with_unwanted_expansion_python)
        end

        it 'ignores irrelevant matrix dimensions' do
          @build_python.matrix_config.expand.should == [
            [[:python, "3.3"]],
            [[:python, "2.7"]]
          ]
        end

        it 'does not touch config' do
          @build_python.config.keys.should include(:rvm)
        end
      end

      it 'copies build attributes' do
        # TODO spec other attributes!
        build = Factory(:build, config: multiple_tests_config)
        build.matrix.map(&:commit_id).uniq.should == [build.commit_id]
      end

      it 'adds a sub-build number to the job number' do
        build = Factory(:build, config: multiple_tests_config)
        build.matrix.map(&:number)[0..3].should == ['1.1', '1.2', '1.3', '1.4']
      end

      describe :exclude_matrix_config do
        it 'excludes a matrix config when all config items are defined in the exclusion' do
          build = Factory(:build, config: multiple_tests_config_with_exculsion)
          matrix_exclusion = {
            exclude: [
              { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.1.x' },
              { rvm: '1.9.2', gemfile: 'gemfiles/rails-2.3.x' }
            ]
          }

          build.matrix.map(&:config).should == [
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-2.3.x', matrix: matrix_exclusion },
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.x', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.x', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.1.x', matrix: matrix_exclusion }
          ]
        end

        it "excludes a matrix config without specifying global env vars in the exclusion" do
          build = Factory(:build, config: multiple_tests_config_with_global_env_and_exclusion)
          matrix_exclusion = { exclude: [{ rvm: "1.9.2", gemfile: "gemfiles/rails-4.0.x" }] }

          build.matrix.map(&:config).should eq([
            { rvm: "1.9.2", gemfile: "gemfiles/rails-3.1.x", matrix: matrix_exclusion, global_env: ["FOO=bar"] },
            { rvm: "2.0.0", gemfile: "gemfiles/rails-3.1.x", matrix: matrix_exclusion, global_env: ["FOO=bar"] },
            { rvm: "2.0.0", gemfile: "gemfiles/rails-4.0.x", matrix: matrix_exclusion, global_env: ["FOO=bar"] },
          ])
        end

        it 'does not exclude a matrix config when the matrix exclusion definition is incomplete' do
          build = Factory(:build, config: multiple_tests_config_with_invalid_exculsion)

          matrix_exclusion = { exclude: [{ rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.x' }] }

          build.matrix.map(&:config).should == [
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.x', env: 'FOO=bar', matrix: matrix_exclusion },
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.0.x', env: 'BAR=baz', matrix: matrix_exclusion },
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.1.x', env: 'FOO=bar', matrix: matrix_exclusion },
            { rvm: '1.8.7', gemfile: 'gemfiles/rails-3.1.x', env: 'BAR=baz', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.x', env: 'FOO=bar', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.0.x', env: 'BAR=baz', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.1.x', env: 'FOO=bar', matrix: matrix_exclusion },
            { rvm: '1.9.2', gemfile: 'gemfiles/rails-3.1.x', env: 'BAR=baz', matrix: matrix_exclusion }
          ]
        end
      end
    end

    describe :include_matrix_config do
      it 'includes a matrix config' do
          build = Factory(:build, config: multiple_tests_config_with_inclusion)

          matrix_inclusion = {
            include: [
              { rvm: '1.9.2', env: 'BAR=xyzzy' }
            ]
          }

          build.matrix.map(&:config).should == [
            { rvm: '1.8.7', env: 'FOO=bar', matrix: matrix_inclusion },
            { rvm: '1.8.7', env: 'BAR=baz', matrix: matrix_inclusion },
            { rvm: '1.9.2', env: 'FOO=bar', matrix: matrix_inclusion },
            { rvm: '1.9.2', env: 'BAR=baz', matrix: matrix_inclusion },
            { rvm: '1.9.2', env: 'BAR=xyzzy', matrix: matrix_inclusion },
          ]
        end
    end

    describe :matrix_config do
      let(:repository) { Factory(:repository) }

      it 'with string values' do
        build = Factory(:build, config: { rvm: '1.8.7', gemfile: 'gemfiles/rails-2.3.x', env: 'FOO=bar' })
        expected = [
          [[:rvm,     '1.8.7']],
          [[:gemfile, 'gemfiles/rails-2.3.x']],
          [[:env,     'FOO=bar']]
        ]
        build.matrix_config.should == expected
      end

      it 'does not decrypt secure env vars' do
        env    = repository.key.secure.encrypt('FOO=bar')
        env    = env.symbolize_keys
        config = { rvm: '1.8.7', gemfile: 'gemfiles/rails-2.3.x', env: env }
        build = Factory(:build, repository: repository, config: config)

        expected = [
                    [[:rvm,     '1.8.7']],
                    [[:gemfile, 'gemfiles/rails-2.3.x']],
                    [[:env,     env]]
                   ]
        build.matrix_config.should == expected
      end

      it 'with two Rubies and Gemfiles' do
        build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'], gemfile: ['gemfiles/rails-2.3.x', 'gemfiles/rails-3.0.x'] })
        expected = [
          [[:rvm, '1.8.7'], [:rvm, '1.9.2']],
          [[:gemfile, 'gemfiles/rails-2.3.x'], [:gemfile, 'gemfiles/rails-3.0.x']]
        ]
        build.matrix_config.should == expected
      end

      it 'with unequal number of Rubies, env variables and Gemfiles' do
        build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2', 'ree'], gemfile: ['gemfiles/rails-3.0.x'], env: ['DB=postgresql', 'DB=mysql'] })
        build.matrix_config.should == [
          [[:rvm, '1.8.7'], [:rvm, '1.9.2'], [:rvm, 'ree']],
          [[:gemfile, 'gemfiles/rails-3.0.x'], [:gemfile, 'gemfiles/rails-3.0.x'], [:gemfile, 'gemfiles/rails-3.0.x']],
          [[:env, 'DB=postgresql'], [:env, 'DB=mysql'], [:env, 'DB=mysql']]
        ]
      end

      it 'with an array of Rubies and a single Gemfile' do
        build = Factory(:build, config: { rvm: ['1.8.7', '1.9.2'], gemfile: 'gemfiles/rails-2.3.x' })
        build.matrix_config.should == [
          [[:rvm, '1.8.7'], [:rvm, '1.9.2']],
          [[:gemfile, 'gemfiles/rails-2.3.x'], [:gemfile, 'gemfiles/rails-2.3.x']]
        ]
      end
    end
  end

  describe 'for Scala projects' do
    it 'with a single Scala version given as a string' do
      build = Factory(:build, config: { language: 'scala', scala: '2.8.2', env: 'NETWORK=false' })
      expected = [
        [[:env, 'NETWORK=false']],
        [[:scala, '2.8.2']]
      ]
      build.matrix_config.should == expected
    end

    it 'with multiple Scala versions and no env variables' do
      build = Factory(:build, config: { language: 'scala', scala: ['2.8.2', '2.9.1']})
      expected = [
         [[:scala, '2.8.2'], [:scala, '2.9.1']]
       ]
      build.matrix_config.should == expected
    end

    it 'with a single Scala version passed in as array and two env variables' do
      build = Factory(:build, config: { language: 'scala', scala: ['2.8.2'], env: ['STORE=postgresql', 'STORE=redis'] })
      build.matrix_config.should == [
        [[:env, 'STORE=postgresql'], [:env, 'STORE=redis']],
        [[:scala, '2.8.2'], [:scala, '2.8.2']]
      ]
    end
  end

  describe 'matrix_for' do
    it 'selects matching builds' do
      build = Factory(:build, config: { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => '1.8.7', 'env' => 'DB=sqlite3' }).should == [build.matrix[0]]
    end

    it 'does not select builds with non-matching values' do
      build = Factory(:build, config: { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => 'nomatch', 'env' => 'DB=sqlite3' }).should be_empty
    end

    it 'does not select builds with non-matching keys' do
      build = Factory(:build, config: { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] })
      build.matrix_for({ 'rvm' => '1.8.7', 'nomatch' => 'DB=sqlite3' }).should == [build.matrix[0], build.matrix[1]]
    end
  end

  describe 'matrix_keys_for' do
    let(:config_default_lang) { { 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] } }
    let(:config_non_def_lang) { { 'language' => 'scala', 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] } }
    let(:config_lang_array)   { { 'language' => ['scala'], 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] } }
    let(:config_unrecognized) { { 'language' => 'bash', 'rvm' => ['1.8.7', '1.9.2'], 'env' => ['DB=sqlite3', 'DB=postgresql'] } }

    it 'only selects appropriate keys' do
      Build.matrix_keys_for(config_default_lang).should == [:rvm, :env]
      Build.matrix_keys_for(config_non_def_lang).should == [:env]
      Build.matrix_keys_for(config_lang_array).should   == [:env]
      Build.matrix_keys_for(config_unrecognized).should == [:rvm, :env]
    end
  end
end
