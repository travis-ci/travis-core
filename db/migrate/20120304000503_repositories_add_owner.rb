class RepositoriesAddOwner < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.references :owner, :polymorphic => true
    end
  end
end

