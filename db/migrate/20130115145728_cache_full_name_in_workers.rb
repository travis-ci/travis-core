class CacheFullNameInWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :full_name, :string
    add_index :workers, :full_name
  end
end
