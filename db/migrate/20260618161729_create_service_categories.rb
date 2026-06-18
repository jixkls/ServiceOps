class CreateServiceCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :service_categories do |t|
      t.string :name
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
