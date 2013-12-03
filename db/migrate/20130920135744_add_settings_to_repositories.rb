class AddSettingsToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :settings, :text
  end
end
