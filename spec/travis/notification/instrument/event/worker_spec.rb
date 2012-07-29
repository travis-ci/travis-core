# Deactivated. See lib/travis/event/handler/worker.rb
#
# require 'spec_helper'
#
# describe Travis::Notification::Instrument::Event::Handler::Worker do
#   include Travis::Testing::Stubs
#
#   let(:handler)   { Travis::Event::Handler::Worker.new('job:test:created', test) }
#   let(:publisher) { Travis::Notification::Publisher::Memory.new }
#   let(:event)     { publisher.events[1] }
#
#   before :each do
#     Travis::Notification.publishers.replace([publisher])
#     handler.stubs(:handle)
#     handler.stubs(:job).returns(test)
#     test.stubs(:enqueue)
#     handler.notify
#   end
#
#   it 'publishes a payload' do
#     event.except(:payload).should == {
#       :message => "travis.event.handler.worker.notify:completed",
#       :uuid => Travis.uuid
#     }
#     event[:payload].should == {
#       :msg => 'Travis::Event::Handler::Worker#notify(job:test:created) for #<Job::Test id=1>',
#       :object_id => 1,
#       :object_type => 'Job::Test',
#       :repository => 'svenfuchs/minimal',
#       :request_id => 1,
#       :event => 'job:test:created'
#     }
#   end
# end
