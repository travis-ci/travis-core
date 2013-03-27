class AddPullRequestNumberToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :pull_request_number, :integer
  end
end
