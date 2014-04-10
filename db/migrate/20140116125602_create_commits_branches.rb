class CreateCommitsBranches < ActiveRecord::Migration
  def change
    create_table :commits_branches do |t|
      t.references :commit
      t.references :branch
      t.references :request

      t.foreign_key :commits, dependent: :delete
      t.foreign_key :branches, dependent: :delete
      t.foreign_key :requests, dependent: :delete

      t.timestamps
    end

    add_index :commits_branches, [:commit_id, :branch_id], unique: true
  end
end
