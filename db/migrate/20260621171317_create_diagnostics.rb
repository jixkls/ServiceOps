class CreateDiagnostics < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnostics do |t|
      t.references :service_order, null: false, foreign_key: true, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.string :summary
      t.text :technical_details

      t.timestamps
    end
  end
end
