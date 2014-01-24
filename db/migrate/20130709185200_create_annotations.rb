class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :job_id, null: false
      t.string :url
      t.text :description, null: false
      t.string :image_url
      t.string :image_alt

      t.timestamps
    end
  end
end
