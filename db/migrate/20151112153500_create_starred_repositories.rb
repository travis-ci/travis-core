class CreateStarredRepositories < ActiveRecord::Migration
  def self.up
    create_table :starred_repositories do |t|
      t.integer   :repository_id
      t.integer   :user_id
      t.timestamps
    end

    add_index :starred_repositories, :user_id
  end


  def self.down
    drop_table :starred_repositories
  end
end
