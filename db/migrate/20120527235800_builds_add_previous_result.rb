class BuildsAddPreviousResult < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.integer :previous_result
    end
  end
end

