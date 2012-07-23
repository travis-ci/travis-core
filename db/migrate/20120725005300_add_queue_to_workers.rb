class AddQueueToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :queue, :string
  end
end
