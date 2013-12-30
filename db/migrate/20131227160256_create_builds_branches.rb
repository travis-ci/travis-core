class CreateBuildsBranches < ActiveRecord::Migration
  def change
    create_table :builds_branches do |t|
      t.references :build, null: false
      t.references :branch, null: false
      t.foreign_key :builds, dependent: :delete
      t.foreign_key :branches, dependent: :delete

      t.timestamps
    end

    add_index :builds_branches, :build_id
    add_index :builds_branches, :branch_id
    add_index :builds_branches, [:build_id, :branch_id], unique: true
  end
end
