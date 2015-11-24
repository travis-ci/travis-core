class CreateStars < ActiveRecord::Migration
  def self.up
    create_table :stars do |t|
      t.integer   :repository_id
      t.integer   :user_id
      t.timestamps
    end

    add_index :stars, :user_id
  end


  def self.down
    drop_table :stars
  end
end
