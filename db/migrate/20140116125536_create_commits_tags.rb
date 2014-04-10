class CreateCommitsTags < ActiveRecord::Migration
  def change
    create_table :commits_tags do |t|
      t.references :commit
      t.references :tag
      t.references :request

      t.foreign_key :commits, dependent: :delete
      t.foreign_key :tags, dependent: :delete
      t.foreign_key :requests, dependent: :delete

      t.timestamps
    end

    add_index :commits_tags, [:commit_id, :tag_id], unique: true
  end
end
