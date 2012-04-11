class BuildsAddOwner < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.references :owner, :polymorphic => true
    end
  end
end

