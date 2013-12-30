class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.references :repository, null: false
      t.references :last_build
      t.foreign_key :repositories
      t.foreign_key :builds, column: :last_build_id

      t.timestamps
    end

    add_index :branches, :repository_id
    add_index :branches, [:name, :repository_id], unique: true
  end
end
