class CacheFullNameInWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :full_name, :string
    remove_index :workers, [:name, :host]
    add_index :workers, :full_name
  end
end
