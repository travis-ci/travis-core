class RequestsAddIndexOnHeadCommit < ActiveRecord::Migration
  def self.up
    add_index :requests, :head_commit
  end

  def self.down
    remove_index :requests, :head_commit
  end
end
