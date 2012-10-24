# require 'spec_helper'
#
# describe Travis::Event::Handler::Trail do
#   include Travis::Testing::Stubs
#
#   let(:handler) { Travis::Event::Handler::Trail.any_instance }
#
#   before :each do
#     Travis::Event.stubs(:subscribers).returns [:trail]
#     Travis::Features.start
#     Travis::Features.enable_for_all(:event_trail)
#   end
#
#   describe 'does not persist anything unless activated' do
#     before :each do
#       Travis::Features.disable_for_all(:event_trail)
#       handler.expects(:notify).never
#       Travis::Event.dispatch('job:test:created', test)
#     end
#   end
#
#   describe 'does not persist an event record' do
#     it 'job:log' do
#       handler.expects(:notify).never
#       Travis::Event.dispatch('job:test:log', test)
#     end
#
#     it 'worker:added' do
#       handler.expects(:notify).never
#       Travis::Event.dispatch('worker:added', worker)
#     end
#   end
#
#   describe 'persists an event record' do
#     it 'request:finished' do
#       Event.expects(:create!).with(
#         :source => request,
#         :repository => request.repository,
#         :event => 'request:finished',
#         :data => { :commit => '62aae5f70ceee39123ef', :result => :accepted }
#       )
#       Travis::Event.dispatch('request:finished', request)
#     end
#
#     it 'job:test:created' do
#       Event.expects(:create!).with(
#         :source => test,
#         :repository => test.repository,
#         :event => 'job:test:created',
#         :data => { :commit => '62aae5f70ceee39123ef', :number => '2.1', :result => 0 }
#       )
#       Travis::Event.dispatch('job:test:created', test)
#     end
#
#     it 'job:test:started' do
#       Event.expects(:create!).with(
#         :source => test,
#         :repository => test.repository,
#         :event => 'job:test:started',
#         :data => { :commit => '62aae5f70ceee39123ef', :number => '2.1', :result => 0 }
#       )
#       Travis::Event.dispatch('job:test:started', test)
#     end
#
#     it 'job:test:finished' do
#       Event.expects(:create!).with(
#         :source => test,
#         :repository => test.repository,
#         :event => 'job:test:finished',
#         :data => { :commit => '62aae5f70ceee39123ef', :number => '2.1', :result => 0 }
#       )
#       Travis::Event.dispatch('job:test:finished', test)
#     end
#
#     it 'build:started' do
#       Event.expects(:create!).with(
#         :source => build,
#         :repository => build.repository,
#         :event => 'build:started',
#         :data => { :commit => '62aae5f70ceee39123ef', :type => 'push', :number => 2, :result => 0 }
#       )
#       Travis::Event.dispatch('build:started', build)
#     end
#
#     it 'build:finished' do
#       Event.expects(:create!).with(
#         :source => build,
#         :repository => build.repository,
#         :event => 'build:finished',
#         :data => { :commit => '62aae5f70ceee39123ef', :type => 'push', :number => 2, :result => 0 }
#       )
#       Travis::Event.dispatch('build:finished', build)
#     end
#   end
# end
#
