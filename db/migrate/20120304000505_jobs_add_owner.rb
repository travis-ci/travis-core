class JobsAddOwner < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.references :owner, :polymorphic => true
    end
  end
end
