class AddSettingsToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :settings, :json
  end
end
