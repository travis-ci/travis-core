class AddAnnotationProviderIdToAnnotations < ActiveRecord::Migration
  def change
    add_column(:annotations, :annotation_provider_id, :integer, null: false)
  end
end
