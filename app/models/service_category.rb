class ServiceCategory < ApplicationRecord
  # Bloqueia a exclusão se houver ordens de serviço vinculadas.
  has_many :service_orders, dependent: :restrict_with_error

  validates :name, presence: true
end
