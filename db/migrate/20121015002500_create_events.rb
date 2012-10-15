class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :source, polymorphic: true
      t.belongs_to :repository
      t.string :event
      t.string :data
      t.timestamps
    end
  end
end
