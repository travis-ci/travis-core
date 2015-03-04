class CreateBranches < ActiveRecord::Migration
  def up
    create_table(:branches) do |t|
      t.integer :repository_id, null: false
      t.integer :last_build_id
      t.string  :name, null: false
      t.boolean :exists_on_github, default: true, null: false
      t.timestamps
    end
    add_index(:branches, [:repository_id, :name], unique: true)
  end

  def down
    drop_table(:branches)
  end
end
