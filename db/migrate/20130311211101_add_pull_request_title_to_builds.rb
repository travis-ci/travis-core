class AddPullRequestTitleToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :pull_request_title, :text
  end
end
