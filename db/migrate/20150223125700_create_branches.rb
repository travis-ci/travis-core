class CreateBranches < ActiveRecord::Migration
  def up
    create_table(:branches) do |t|
      t.integer :repository_id, null: false
      t.integer :last_build_id
      t.string  :name
      t.timestamps
    end
    add_index(:branches, [:repository_id, :name])
  end

  def down
    drop_table(:branches)
  end
end
