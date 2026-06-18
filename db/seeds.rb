# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Usuário admin inicial para acessar o painel.
# Idempotente: roda sem duplicar se o usuário já existir.
admin_email = "admin@serviceops.local"
admin_password = ENV.fetch("ADMIN_PASSWORD", "password")

admin = User.find_or_create_by!(email_address: admin_email) do |user|
  user.password = admin_password
  user.role = :admin
end

# Garante o papel de admin mesmo se o usuário já existia antes da coluna role.
admin.update!(role: :admin) unless admin.admin?

puts "Usuário admin pronto: #{admin.email_address} (role: #{admin.role}, senha: #{admin_password})"
