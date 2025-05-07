require 'bcrypt'
require 'securerandom'
require_relative '../domain/entity/user'
require_relative 'repository/memory_user_repository'

module IAM
  module Infrastructure
    class Seeds
      def self.run(user_repository)
        # Verificar si ya existe el usuario admin
        return if user_repository.find_by_email('admin@example.com')

        # Crear usuario administrador inicial
        password_hash = BCrypt::Password.create('admin123')
        admin_user = IAM::Domain::Entity::User.new(
          id: SecureRandom.uuid,
          email: 'admin@example.com',
          password_hash: password_hash
        )

        user_repository.save(admin_user)
        puts "Usuario administrador creado: admin@example.com"
      end
    end
  end
end 