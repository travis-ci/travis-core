require 'spec_helper'

describe Job do
  include Support::ActiveRecord

  describe ".queued" do
    let(:jobs) { [Factory.create(:test), Factory.create(:test), Factory.create(:test)] }

    it "returns jobs that are created but not started or finished" do
      jobs.first.start!
      jobs.third.start!
      jobs.third.finish!

      Job.queued.should include(jobs.second)
      Job.queued.should_not include(jobs.first)
      Job.queued.should_not include(jobs.third)
    end
  end

  describe :append_log! do
    let!(:job) { Factory(:test) }

    it "appends chars to the log artifact" do
      line = "$ bundle install --pa"
      Artifact::Log.expects(:append).with(job.id, line)
      job.append_log!(line)
    end

    it 'notifies observers' do
      Travis::Event.expects(:dispatch).with('job:test:log', job, :_log => 'chars')
      Job::Test.append_log!(job.id, 'chars')
    end
  end

  describe 'before_create' do
    let(:job) { Job::Test.create!(:owner => Factory(:user), :repository => Factory(:repository), :commit => Factory(:commit), :source => Factory(:build)) }

    before :each do
      Job::Test.any_instance.stubs(:enqueueable?).returns(false) # prevent jobs to enqueue themselves on create
    end

    it 'instantiates the log artifact' do
      job.reload.log.should be_instance_of(Artifact::Log)
    end

    it 'sets the state attribute' do
      job.reload.should be_created
    end

    it 'sets the queue attribute' do
      job.reload.queue.should == 'builds.common'
    end
  end

  describe 'duration' do
    it 'returns nil if both started_at is not populated' do
      job = Job.new(:finished_at => Time.now)
      job.duration.should be_nil
    end

    it 'returns nil if both finished_at is not populated' do
      job = Job.new(:started_at => Time.now)
      job.duration.should be_nil
    end

    it 'returns the duration if both started_at and finished_at are populated' do
      job = Job.new(:started_at => 20.seconds.ago, :finished_at => 10.seconds.ago)
      job.duration.should == 10
    end
  end

  describe 'tagging' do
    let(:job) { Factory.create(:test) }

    before :each do
      Job::Tagging.stubs(:rules).returns [
        { 'tag' => 'rake_not_bundled',   'pattern' => 'rake is not part of the bundle.' }
      ]
    end

    it 'should tag a job its log contains a particular string' do
      job.start!
      job.reload.append_log!('rake is not part of the bundle')
      job.finish!

      job.reload.tags.should == "rake_not_bundled"
    end
  end

  describe 'obfuscated config' do
    it 'handles nil env' do
      job = Job.new(:repository => Factory(:repository))
      job.config = { :rvm => '1.8.7', :env => nil }

      job.obfuscated_config.should == {
        :rvm => '1.8.7',
        :env => nil
      }
    end

    it 'leaves regular vars untouched' do
      job = Job.new(:repository => Factory(:repository))
      job.expects(:pull_request?).at_least_once.returns(false)
      job.config = { :rvm => '1.8.7', :env => 'FOO=foo' }

      job.obfuscated_config.should == {
        :rvm => '1.8.7',
        :env => 'FOO=foo'
      }
    end

    it 'obfuscates env vars' do
      job = Job.new(:repository => Factory(:repository))
      job.expects(:pull_request?).at_least_once.returns(false)
      config = { :rvm => '1.8.7',
                 :env => [job.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo']
               }
      job.config = config

      job.obfuscated_config.should == {
        :rvm => '1.8.7',
        :env => 'BAR=[secure] FOO=foo'
      }
    end

    it 'normalizes env vars which are hashes to strings' do
      job = Job.new(:repository => Factory(:repository))
      job.expects(:pull_request?).at_least_once.returns(false)

      config = { :rvm => '1.8.7',
                 :env => [{:FOO => 'bar', :BAR => 'baz'},
                          job.repository.key.secure.encrypt('BAR=barbaz')]
               }
      job.config = config

      job.obfuscated_config.should == {
        :rvm => '1.8.7',
        :env => 'FOO=bar BAR=baz BAR=[secure]'
      }
    end

    context 'when job is from a pull request' do
      let :job do
        job = Job.new(:repository => Factory(:repository))
        job.expects(:pull_request?).returns(true).at_least_once
        job
      end

      it 'removes secure env vars' do
        config = { :rvm => '1.8.7',
                   :env => [job.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo']
                 }
        job.config = config

        job.obfuscated_config.should == {
          :rvm => '1.8.7',
          :env => 'FOO=foo'
        }
      end

      it 'works even if it removes all env vars' do
        config = { :rvm => '1.8.7',
                   :env => [job.repository.key.secure.encrypt('BAR=barbaz')]
                 }
        job.config = config

        job.obfuscated_config.should == {
          :rvm => '1.8.7',
          :env => nil
        }
      end

      it 'normalizes env vars which are hashes to strings' do
        config = { :rvm => '1.8.7',
                   :env => [{:FOO => 'bar', :BAR => 'baz'},
                            job.repository.key.secure.encrypt('BAR=barbaz')]
                 }
        job.config = config

        job.obfuscated_config.should == {
          :rvm => '1.8.7',
          :env => 'FOO=bar BAR=baz'
        }
      end
    end
  end

  describe '#pull_request?' do
    it 'is delegated to commit' do
      commit = Commit.new
      commit.expects(:pull_request?).returns(true)

      job = Job.new
      job.commit = commit
      job.pull_request?.should be_true
    end
  end

  describe 'decrypted config' do
    it 'handles nil env' do
      job = Job.new(:repository => Factory(:repository))
      job.config = { :rvm => '1.8.7', :env => nil }

      job.decrypted_config.should == {
        :rvm => '1.8.7',
        :env => nil
      }
    end

    it 'normalizes env vars which are hashes to strings' do
      job = Job.new(:repository => Factory(:repository))
      job.expects(:pull_request?).at_least_once.returns(false)

      config = { :rvm => '1.8.7',
                 :env => [{:FOO => 'bar', :BAR => 'baz'},
                          job.repository.key.secure.encrypt('BAR=barbaz')]
               }
      job.config = config

      job.decrypted_config.should == {
        :rvm => '1.8.7',
        :env => ["FOO=bar BAR=baz", "SECURE BAR=barbaz"]
      }
    end

    it 'leaves regular vars untouched' do
      job = Job.new(:repository => Factory(:repository))
      job.expects(:pull_request?).returns(false).at_least_once
      job.config = { :rvm => '1.8.7', :env => 'FOO=foo' }

      job.decrypted_config.should == {
        :rvm => '1.8.7',
        :env => ['FOO=foo']
      }
    end

    context 'when job is from a pull request' do
      let :job do
        job = Job.new(:repository => Factory(:repository))
        job.expects(:pull_request?).returns(true).at_least_once
        job
      end

      it 'removes secure env vars' do
        config = { :rvm => '1.8.7',
                   :env => [job.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo']
                 }
        job.config = config

        job.decrypted_config.should == {
          :rvm => '1.8.7',
          :env => ['FOO=foo']
        }
      end

      it 'removes only secured env vars' do
        config = { :rvm => '1.8.7',
                   :env => [job.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo']
                 }
        job.config = config

        job.decrypted_config.should == {
          :rvm => '1.8.7',
          :env => ['FOO=foo']
        }
      end
    end

    context 'when job is *not* from pull request' do
      let :job do
        job = Job.new(:repository => Factory(:repository))
        job.expects(:pull_request?).returns(false).at_least_once
        job
      end

      it 'decrypts env vars' do
        config = { :rvm => '1.8.7',
                   :env => job.repository.key.secure.encrypt('BAR=barbaz')
                 }
        job.config = config

        job.decrypted_config.should == {
          :rvm => '1.8.7',
          :env => ['SECURE BAR=barbaz']
        }
      end

      it 'decrypts only secured env vars' do
        config = { :rvm => '1.8.7',
                   :env => [job.repository.key.secure.encrypt('BAR=barbaz'), 'FOO=foo']
                 }
        job.config = config

        job.decrypted_config.should == {
          :rvm => '1.8.7',
          :env => ['SECURE BAR=barbaz', 'FOO=foo']
        }
      end
    end
  end
end
