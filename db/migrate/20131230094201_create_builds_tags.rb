class CreateBuildsTags < ActiveRecord::Migration
  def change
    create_table :builds_tags do |t|
      t.references :build, null: false
      t.references :tag, null: false
      t.foreign_key :builds, dependent: :delete
      t.foreign_key :tags, dependent: :delete

      t.timestamps
    end

    add_index :builds_tags, :build_id
    add_index :builds_tags, :tag_id
    add_index :builds_tags, [:build_id, :tag_id], unique: true
  end
end
