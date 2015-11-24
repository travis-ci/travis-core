class CreateStars < ActiveRecord::Migration
  def self.up
    create_table :stars do |t|
      t.integer   :repo_id
      t.integer   :user_id
      t.timestamps
    end

    add_index :starred_repositories, :user_id
  end


  def self.down
    drop_table :starred_repositories
  end
end
