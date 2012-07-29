# Deactivated. See lib/travis/event/handler/worker.rb
#
# require 'spec_helper'
#
# describe Travis::Event::Handler::Worker do
#   include Travis::Testing::Stubs
#
#   let(:handler) { Travis::Event::Handler::Worker.new(event, test) }
#
#   describe 'on job:test:created' do
#     let(:event) { 'job:test:created' }
#
#     it 'enqueues the job' do
#       Job::Queueing.expects(:new).with(test).returns(stub(:run => true))
#       handler.handle
#     end
#   end
#
#   describe 'on job:test:finished' do
#     let(:event) { 'job:test:finished' }
#
#     it 'queues queueable jobs on the same queue' do
#       Job::Queueing.expects(:by_owner).with(test.owner)
#       handler.handle
#     end
#   end
#
#   describe 'instrumentation' do
#     let(:handler) { Travis::Event::Handler::Worker.new(:start, test) }
#
#     before :each do
#       handler.stubs(:handle)
#       Travis::Event.stubs(:subscribers).returns [:worker]
#       Job::Queueing.any_instance.stubs(:run)
#     end
#
#     it 'instruments with "travis.event.handler.worker.notify:*"' do
#       ActiveSupport::Notifications.stubs(:publish)
#       ActiveSupport::Notifications.expects(:publish).with do |event, data|
#         event =~ /travis.event.handler.worker.notify/ && data[:target].is_a?(Travis::Event::Handler::Worker)
#       end
#       Travis::Event.dispatch('job:test:created', test)
#     end
#
#     it 'meters on "travis.event.handler.worker.notify:completed"' do
#       Metriks.expects(:timer).with('v1.travis.event.handler.worker.notify:completed').returns(stub('timer', :update => true))
#       handler.notify
#     end
#   end
# end
