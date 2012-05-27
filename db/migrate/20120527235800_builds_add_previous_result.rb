class BuildsAddLastResult < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.integer :last_result
    end
  end
end

