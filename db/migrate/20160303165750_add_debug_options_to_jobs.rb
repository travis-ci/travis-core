class AddDebugOptionsToJobs < ActiveRecord::Migration

  def up
    add_column :jobs, :debug_options, :text
  end

  def down
    remove_column :jobs, :debug_options
  end
end
