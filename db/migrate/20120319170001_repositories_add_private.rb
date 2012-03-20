class RepositoriesAddPrivate < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.boolean :private, :default => false
    end
  end
end
