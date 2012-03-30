class RequestsAddOwner < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.references :owner, :polymorphic => true
    end
  end
end
