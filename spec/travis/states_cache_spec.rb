require 'spec_helper'

module Travis
  describe StatesCache do
    let(:build) { stub('build', finished_at: Time.new(2013, 4, 22, 22, 10, 0, "+02:00"), state: 'passed') }
    let(:adapter) { StatesCache::TestAdapter.new }
    subject { StatesCache.new(adapter: adapter) }

    it 'delegates #write to adapter and gets data from build' do
      adapter.expects(:write).with(1, 'master', { finished_at: '2013-04-22 22:10:00 +0200', state: 'passed' }.stringify_keys)

      subject.write(1, 'master', build)
    end

    it 'delegates #fetch to adapter' do
      adapter.expects(:fetch).with(1, 'master').returns({ foo: 'bar' })

      subject.fetch(1, 'master').should == { foo: 'bar' }
    end

    describe 'integration' do
      let(:client) { Dalli::Client.new('localhost:11211') }
      let(:adapter) { StatesCache::MemcachedAdapter.new(client: client) }

      before do
        begin
          client.flush
        rescue Dalli::DalliError => e
          pending "Dalli can't run properly, skipping. Cause: #{e.message}"
        end
      end

      it 'saves the state for given branch and globally' do
        subject.write(1, 'master', build)
        subject.fetch(1)['state'].should == 'passed'
        subject.fetch(1, 'master')['state'].should == 'passed'

        subject.fetch(2).should be_nil
        subject.fetch(2, 'master').should be_nil
      end

      it 'updates the state only if the info is newer' do
        build = stub('build', finished_at: Time.new(2013, 1, 1, 12, 0, 0, "+02:00"), state: 'passed')
        subject.write(1, 'master', build)

        subject.fetch(1, 'master')['state'].should == 'passed'

        build = stub('build', finished_at: Time.new(2013, 2, 1, 12, 0, 0, "+02:00"), state: 'failed')
        subject.write(1, 'development', build)

        subject.fetch(1, 'master')['state'].should == 'passed'
        subject.fetch(1, 'development')['state'].should == 'failed'
        subject.fetch(1)['state'].should == 'failed'

        build = stub('build', finished_at: Time.new(2013, 1, 15, 12, 0, 0, "+02:00"), state: 'errored')
        subject.write(1, 'master', build)

        subject.fetch(1, 'master')['state'].should == 'errored'
        subject.fetch(1, 'development')['state'].should == 'failed'
        subject.fetch(1)['state'].should == 'failed'
      end
    end

    describe StatesCache::MemcachedAdapter do
      let(:client) { stub('client') }
      subject { StatesCache::MemcachedAdapter.new(client: client) }

      it 'fetches the data for given id as JSON' do
        json = '{ "state": "passed", "finished_at": "2013-04-22T22:10" }'
        client.expects(:get).with('state:1').returns(json)

        subject.fetch(1).should == { 'state' => 'passed', 'finished_at' => '2013-04-22T22:10' }
      end

      it 'writes for both a branch and default state' do
        time = '2013-04-22T22:10'
        data = { 'finished_at' => time }

        subject.expects(:update?).with(1, nil, time).returns(true)
        subject.expects(:update?).with(1, 'master', time).returns(true)

        client.expects(:set).with('state:1', data.to_json)
        client.expects(:set).with('state:1-master', data.to_json)

        subject.write(1, 'master', data)
      end

      context '#update?' do
        it 'returns true if persisted data is older than data passed as an argument' do
          subject.expects(:fetch).with(1, nil).returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, nil, '2013-04-22T22:14').should be_true

          subject.expects(:fetch).with(1, 'master').returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, 'master', '2013-04-22T22:14').should be_true
        end

        it 'returns false if persisted data is younger than data passed as an argument' do
          subject.expects(:fetch).with(1, nil).returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, nil, '2013-04-22T22:10').should be_false

          subject.expects(:fetch).with(1, 'master').returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, 'master', '2013-04-22T22:10').should be_false
        end

        it 'returns true if persisted data is the same age' do
          subject.expects(:fetch).with(1, nil).returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, nil, '2013-04-22T22:12').should be_false

          subject.expects(:fetch).with(1, 'master').returns({ 'finished_at' => '2013-04-22T22:12' })
          subject.update?(1, 'master', '2013-04-22T22:12').should be_false
        end
      end
    end
  end
end
