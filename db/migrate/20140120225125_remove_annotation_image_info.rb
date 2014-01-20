class RemoveAnnotationImageInfo < ActiveRecord::Migration
  def up
    remove_column :annotations, :image_url
    remove_column :annotations, :image_alt
  end

  def down
    add_column :annotations, :image_url, :string
    add_column :annotations, :image_alt, :string
  end
end
