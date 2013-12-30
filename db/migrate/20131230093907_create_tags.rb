class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :last_build
      t.references :repository, null: false
      t.foreign_key :repositories
      t.foreign_key :builds, column: :last_build_id

      t.timestamps
    end

    add_index :tags, :repository_id
    add_index :tags, [:name, :repository_id], unique: true
  end
end
