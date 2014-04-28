require "spec_helper"

describe Travis::Github::Services::SyncUser::ResetToken do
  let(:gh) { stub("gh", post: { "token" => "new-token" }) }
  let(:user) { stub("user", github_oauth_token: "old-token", update_attributes!: nil) }

  subject { described_class.new(user) }

  before do
    subject.gh = gh
    subject.config = stub("oauth2 config", client_id: "the-client-id", client_secret: "the-client-secret")
  end

  it "resets the token on GitHub" do
    gh.expects(:post).with("/applications/the-client-id/tokens/old-token", {}).returns({ "token" => "new-token" })
    subject.run
  end

  it "stores the new token" do
    user.expects(:update_attributes!).with(github_oauth_token: "new-token")
    subject.run
  end
end
