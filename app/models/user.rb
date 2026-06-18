class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Ordens em que este usuário é o técnico responsável.
  # Se o usuário for removido, as ordens apenas ficam sem responsável (nullify).
  has_many :assigned_service_orders,
           class_name: "ServiceOrder",
           foreign_key: :assigned_user_id,
           dependent: :nullify,
           inverse_of: :assigned_user

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, {
    admin: "admin",
    technician: "technician",
    attendant: "attendant"
  }
end
