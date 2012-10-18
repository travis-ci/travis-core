class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.belongs_to :recipient, :polymorphic => true
      t.string :kind
      t.string :message
      t.boolean :expired
      t.timestamps
    end
  end
end

