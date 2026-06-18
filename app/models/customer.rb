class Customer < ApplicationRecord
  # Bloqueia a exclusão se houver ordens de serviço vinculadas (preserva histórico).
  has_many :service_orders, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true
end
