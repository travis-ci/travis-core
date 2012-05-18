require 'spec_helper'

# describe Travis::Github::ServiceHook do
#   describe "add" do
#     it "should add a service hook" do
#       client = stub('client')
#       client.expects(:subscribe_service_hook).with('owner/name', 'Travis', {})
#       Octokit::Client.stubs(:new).with(:oauth_token => 't0k3n').returns(client)
#       Travis::Github::ServiceHook.add('owner', 'name', 't0k3n', {})
#     end
#
#     it "should raise an error when an unprocessable entity error occurs" do
#       Octokit::Client.stubs(:new).raises(Octokit::UnprocessableEntity)
#       expect {
#         Travis::Github::ServiceHook.add('owner', 'name', 't0k3n', {})
#       }.to raise_error Travis::Github::ServiceHookError, 'error subscribing to the GitHub push event'
#     end
#
#     it "should raise an error when an unauthorized error occurs" do
#       Octokit::Client.stubs(:new).raises(Octokit::Unauthorized)
#       expect {
#         Travis::Github::ServiceHook.add('owner', 'name', 't0k3n', {})
#       }.to raise_error Travis::Github::ServiceHookError, 'error authorizing with given GitHub OAuth token'
#     end
#
#   end
#
#   describe "remove" do
#     it "should remove a service hook" do
#       client = stub('client')
#       client.expects(:unsubscribe_service_hook).with('owner/name', 'Travis')
#       Octokit::Client.stubs(:new).with(:oauth_token => 't0k3n').returns(client)
#       Travis::Github::ServiceHook.remove('owner', 'name', 't0k3n')
#     end
#
#     it "should raise an error when an unprocessable entity error occurs" do
#       Octokit::Client.stubs(:new).raises(Octokit::UnprocessableEntity)
#       expect {
#         Travis::Github::ServiceHook.remove('owner', 'name', 't0k3n')
#       }.to raise_error Travis::Github::ServiceHookError, 'error unsubscribing from the GitHub push event'
#     end
#
#   end
#
# end
