class EventsChangeDataToText < ActiveRecord::Migration
  def change
    change_column :events, :data, :text
  end
end
