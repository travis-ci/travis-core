class BuildsAddIndexOnFinishedAt < ActiveRecord::Migration
  def change
    add_index 'builds', 'finished_at'
  end
end
