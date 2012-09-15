class CommitsAddIndexOnBranch < ActiveRecord::Migration
  def change
    add_index 'commits', 'branch'
  end
end
