class JobsAddIndexOnCreatedAt < ActiveRecord::Migration
  def change
    add_index 'jobs', 'created_at'
  end
end
