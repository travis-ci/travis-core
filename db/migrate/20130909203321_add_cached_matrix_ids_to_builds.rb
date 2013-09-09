class AddCachedMatrixIdsToBuilds < ActiveRecord::Migration
  def up
   execute "ALTER TABLE builds ADD COLUMN cached_matrix_ids integer[]"
  end

  def down
   execute "ALTER TABLE builds DROP COLUMN cached_matrix_ids"
  end
end
