class CreateStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :status_histories do |t|
      t.references :service_order, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.text :note

      t.timestamps
    end

    add_index :status_histories, %i[service_order_id created_at]
  end
end
