class CreateServiceOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :service_orders do |t|
      t.string :code
      t.references :customer, null: false, foreign_key: true
      # Técnico responsável: opcional (pode não estar atribuído ainda) e aponta para a tabela users.
      t.references :assigned_user, null: true, foreign_key: { to_table: :users }
      t.references :service_category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :status
      t.string :priority
      t.string :public_token
      t.datetime :opened_at
      t.datetime :finished_at

      t.timestamps
    end

    # Identificadores públicos/únicos: não podem repetir.
    add_index :service_orders, :public_token, unique: true
    add_index :service_orders, :code, unique: true
  end
end
