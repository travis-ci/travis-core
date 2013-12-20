require 'spec_helper'

describe Build do
  include Support::ActiveRecord

  let(:repository) { Factory(:repository) }

  it 'caches matrix ids' do
    build = Factory.create(:build, config: { rvm: ['1.9.3', '2.0.0'] })
    build.cached_matrix_ids.should == build.matrix_ids
  end

  it 'returns nil if cached_matrix_ids are not set' do
    build = Factory.create(:build)
    build.update_column(:cached_matrix_ids, nil)
    build.reload.cached_matrix_ids.should be_nil
  end

  it 'does not expand on :os' do
    build = Factory.create(:build, config: { rvm: ['1.9.3', '2.0.0'], os: ['osx', 'linux']})
    build.matrix.map(&:config).should == [{:rvm=>"1.9.3"}, {:rvm=>"2.0.0"}]
  end

  it 'is cancelable if at least one job is cancelable' do
    jobs = [
      Factory.build(:test),
      Factory.build(:test)
    ]

    jobs.first.stubs(:cancelable?).returns(true)
    jobs.second.stubs(:cancelable?).returns(false)

    build = Factory.build(:build, matrix: jobs)
    build.should be_cancelable
  end

  it 'is not cancelable if none of the jobs are cancelable' do
    jobs = [
      Factory.build(:test),
      Factory.build(:test)
    ]

    jobs.first.stubs(:cancelable?).returns(false)
    jobs.second.stubs(:cancelable?).returns(false)

    build = Factory.build(:build, matrix: jobs)
    build.should_not be_cancelable
  end

  describe '#secure_env_enabled?' do
    it 'returns true if we\'re not dealing with pull request' do
      build = Factory.build(:build)
      build.stubs(:pull_request?).returns(false)
      build.secure_env_enabled?.should be_true
    end

    it 'returns true if pull request is from the same repository' do
      build = Factory.build(:build)
      build.stubs(:pull_request?).returns(true)
      build.stubs(:same_repo_pull_request?).returns(true)
      build.secure_env_enabled?.should be_true
    end

    it 'returns false if pull request is not from the same repository' do
      build = Factory.build(:build)
      build.stubs(:pull_request?).returns(true)
      build.stubs(:same_repo_pull_request?).returns(false)
      build.secure_env_enabled?.should be_false
    end
  end

  describe 'class methods' do
    describe 'recent' do
      it 'returns recent builds ordered by started time descending' do
        Factory(:build, state: 'passed', started_at: 2.second.ago)
        Factory(:build, state: 'started', started_at: 1.second.ago)
        Factory(:build, state: 'created', started_at: nil)

        Build.recent.all.map(&:state).should == ['started', 'passed']
      end
    end

    describe 'was_started' do
      it 'returns builds that are either started or finished' do
        Factory(:build, state: 'passed')
        Factory(:build, state: 'started')
        Factory(:build, state: 'created')

        Build.was_started.map(&:state).sort.should == ['passed', 'started']
      end
    end

    describe 'on_branch' do
      it 'returns builds that are on any of the given branches' do
        Factory(:build, commit: Factory(:commit, branch: 'master'))
        Factory(:build, commit: Factory(:commit, branch: 'develop'))
        Factory(:build, commit: Factory(:commit, branch: 'feature'))

        Build.on_branch('master,develop').map(&:commit).map(&:branch).sort.should == ['develop', 'master']
      end

      it 'does not include pull requests' do
        Factory(:build, commit: Factory(:commit, branch: 'no-pull'), request: Factory(:request, event_type: 'pull_request'))
        Factory(:build, commit: Factory(:commit, branch: 'no-pull'), request: Factory(:request, event_type: 'push'))
        Build.on_branch('no-pull').count.should be == 1
      end
    end

    describe 'older_than' do
      before do
        5.times { |i| Factory(:build, number: i) }
        Build.stubs(:per_page).returns(2)
      end

      context "when a Build is passed in" do
        subject { Build.older_than(Build.new(number: 3)) }

        it "should limit the results" do
          should have(2).items
        end

        it "should return older than the passed build" do
          subject.map(&:number).should == ['2', '1']
        end
      end

      context "when a number is passed in" do
        subject { Build.older_than(3) }

        it "should limit the results" do
          should have(2).items
        end

        it "should return older than the passed build" do
          subject.map(&:number).should == ['2', '1']
        end
      end

      context "when not passing a build" do
        subject { Build.older_than() }

        it "should limit the results" do
          should have(2).item
        end
      end
    end

    describe 'paged' do
      it 'limits the results to the `per_page` value' do
        3.times { Factory(:build) }
        Build.stubs(:per_page).returns(1)

        Build.paged({}).should have(1).item
      end

      it 'uses an offset' do
        3.times { |i| Factory(:build) }
        Build.stubs(:per_page).returns(1)

        builds = Build.paged({page: 2})
        builds.should have(1).item
        builds.first.number.should == '2'
      end
    end

    describe 'next_number' do
      it 'returns the next build number' do
        1.upto(3) do |number|
          Factory(:build, repository: repository, number: number)
          repository.builds.next_number.should == number + 1
        end
      end
    end

    describe 'pushes' do
      before do
        Factory(:build)
        Factory(:build, request: Factory(:request, event_type: 'pull_request'))
      end

      it "returns only builds which have Requests with an event_type of push" do
        Build.pushes.all.count.should == 1
      end
    end

    describe 'pull_requests' do
      before do
        Factory(:build)
        Factory(:build, request: Factory(:request, event_type: 'pull_request'))
      end

      it "returns only builds which have Requests with an event_type of pull_request" do
        Build.pull_requests.all.count.should == 1
      end
    end
  end

  describe 'creation' do
    describe 'previous_state' do
      it 'is set to the last finished build state on the same branch' do
        Factory(:build, state: 'failed')
        Factory(:build).reload.previous_state.should == 'failed'
      end

      it 'is set to the last finished build state on the same branch (disregards non-finished builds)' do
        Factory(:build, state: 'failed')
        Factory(:build, state: 'started')
        Factory(:build).reload.previous_state.should == 'failed'
      end

      it 'is set to the last finished build state on the same branch (disregards other branches)' do
        Factory(:build, state: 'failed')
        Factory(:build, state: 'passed', commit: Factory(:commit, branch: 'something'))
        Factory(:build).reload.previous_state.should == 'failed'
      end
    end
  end

  describe 'instance methods' do
    it 'sets its number to the next build number on creation' do
      1.upto(3) do |number|
        Factory(:build).reload.number.should == number.to_s
      end
    end

    it 'sets previous_state to nil if no last build exists on the same branch' do
      build = Factory(:build, commit: Factory(:commit, branch: 'master'))
      build.reload.previous_state.should == nil
    end

    it 'sets previous_state to the result of the last build on the same branch if exists' do
      build = Factory(:build, state: :canceled, commit: Factory(:commit, branch: 'master'))
      build = Factory(:build, commit: Factory(:commit, branch: 'master'))
      build.reload.previous_state.should == 'canceled'
    end

    describe 'config' do
      it 'defaults to an empty hash' do
        Build.new.config.should == {}
      end

      it 'deep_symbolizes keys on write' do
        build = Factory(:build, config: { 'foo' => { 'bar' => 'bar' } })
        build.config[:foo][:bar].should == 'bar'
      end

      it 'normalizes env vars global and matrix which are hashes to strings' do
        env = {
          'global' => [{FOO: 'bar', BAR: 'baz'}],
          'matrix' => [{ONE: 1, TWO: '2'}]
        }
        config = { 'env' => env }
        build = Factory(:build, config: config)

        build.config.should == {
          env: ["ONE=1 TWO=2"],
          global_env: ["FOO=bar BAR=baz"]
        }
      end

      it 'works fine even if matrix part of env is undefined' do
        env = { 'global' => ['FOO=bar'] }
        config = { 'env' => env }
        build = Factory(:build, config: config)

        build.config.should == { global_env: ["FOO=bar"] }
      end

      it 'works fine even if global part of env is undefined' do
        env = { 'matrix' => ['FOO=bar'] }
        config = { 'env' => env }
        build = Factory(:build, config: config)

        build.config.should == { env: ["FOO=bar"] }
      end

      it 'squashes matrix and global keys to save config as an array, not as a hash' do
        env = {
          'global' => ['FOO=bar'],
          'matrix' => [['BAR=baz', 'BAZ=qux'], 'QUX=foo']
        }
        config = { 'env' => env }
        build = Factory(:build, config: config)

        build.config.should == {
          global_env: ["FOO=bar"],
          env: [["BAR=baz", "BAZ=qux"], "QUX=foo"]
        }
      end
    end

    describe 'obfuscated config' do
      it 'normalizes env vars which are hashes to strings' do
        build  = Build.new(repository: Factory(:repository))
        config = {
          env: [[build.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo'], [{ONE: 1, TWO: '2'}]]
        }
        build.config = config

        build.obfuscated_config.should == {
          env: ['BAR=[secure] FOO=foo', 'ONE=1 TWO=2']
        }
      end

      it 'leaves regular vars untouched' do
        build = Build.new(repository: Factory(:repository))
        build.config = { rvm: ['1.8.7'], env: ['FOO=foo'] }

        build.obfuscated_config.should == {
          rvm: ['1.8.7'],
          env: ['FOO=foo']
        }
      end

      it 'obfuscates env vars' do
        build  = Build.new(repository: Factory(:repository))
        build.config = {
          rvm: ['1.8.7'],
          env: [[build.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo'], 'BAR=baz']
        }

        build.obfuscated_config.should == {
          rvm: ['1.8.7'],
          env: ['BAR=[secure] FOO=foo', 'BAR=baz']
        }
      end

      it 'obfuscates env vars which are not in nested array' do
        build  = Build.new(repository: Factory(:repository))
        build.config = {
          rvm: ['1.8.7'],
          env: [build.repository.key.secure.encrypt('BAR=barbaz')]
        }

        build.obfuscated_config.should == {
          rvm: ['1.8.7'],
          env: ['BAR=[secure]']
        }
      end

      it 'works with nil values' do
        build  = Build.new(repository: Factory(:repository))
        build.config = { rvm: ['1.8.7'] }
        build.config[:env] = [[nil, {secure: ''}]]
        build.obfuscated_config.should == { rvm: ['1.8.7'], env:  [''] }
      end

      it 'does not make an empty env key an array but leaves it empty' do
        build  = Build.new(repository: Factory(:repository))
        build.config = { rvm: ['1.8.7'], env:  nil }
        build.obfuscated_config.should == { rvm: ['1.8.7'], env:  nil }
      end

      it 'removes source key' do
        build  = Build.new(repository: Factory(:repository))
        build.config = { rvm: ['1.8.7'], source_key: '1234' }
        build.obfuscated_config.should == { rvm: ['1.8.7'] }
      end
    end

    describe :pending? do
      it 'returns true if the build is finished' do
        build = Factory(:build, state: :finished)
        build.pending?.should be_false
      end

      it 'returns true if the build is not finished' do
        build = Factory(:build, state: :started)
        build.pending?.should be_true
      end
    end

    describe :passed? do
      it 'passed? returns true if state equals :passed' do
        build = Factory(:build, state: :passed)
        build.passed?.should be_true
      end

      it 'passed? returns true if result does not equal :passed' do
        build = Factory(:build, state: :failed)
        build.passed?.should be_false
      end
    end

    describe :color do
      it 'returns "green" if the build has passed' do
        build = Factory(:build, state: :passed)
        build.color.should == 'green'
      end

      it 'returns "red" if the build has failed' do
        build = Factory(:build, state: :failed)
        build.color.should == 'red'
      end

      it 'returns "yellow" if the build is pending' do
        build = Factory(:build, state: :started)
        build.color.should == 'yellow'
      end
    end

    it 'saves event_type before create' do
      build = Factory(:build,  request: Factory(:request, event_type: 'pull_request'))
      build.event_type.should == 'pull_request'

      build = Factory(:build,  request: Factory(:request, event_type: 'push'))
      build.event_type.should == 'push'
    end

    it 'saves pull_request_title before create' do
      payload = { 'pull_request' => { 'title' => 'A pull request' } }
      build = Factory(:build,  request: Factory(:request, event_type: 'pull_request', payload: payload))
      build.pull_request_title.should == 'A pull request'
    end

    it 'saves branch before create' do
      build = Factory(:build,  commit: Factory(:commit, branch: 'development'))
      build.branch.should == 'development'
    end

    describe 'reset' do
      let(:build) { Factory(:build, state: 'finished') }

      before :each do
        build.matrix.each { |job| job.stubs(:reset) }
      end

      it 'sets the state to :created' do
        build.reset
        build.state.should == :created
      end

      it 'resets related attributes' do
        build.reset
        build.duration.should be_nil
        build.finished_at.should be_nil
      end

      it 'resets each job if :reset_matrix is given' do
        build.matrix.each { |job| job.expects(:reset) }
        build.reset(reset_matrix: true)
      end

      it 'does not reset jobs if :reset_matrix is not given' do
        build.matrix.each { |job| job.expects(:reset).never }
        build.reset
      end

      it 'notifies obsevers' do
        Travis::Event.expects(:dispatch).with('build:created', build)
        build.reset
      end
    end
  end
end
