class AddTagToCommitsAndBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :tag, :string
    add_column :commits, :tag, :string
  end
end
