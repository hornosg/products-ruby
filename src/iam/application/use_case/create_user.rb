require 'bcrypt'
require 'securerandom'
require_relative '../../domain/entity/user'
require_relative '../../domain/port/user_repository'

module IAM
  module Application
    module UseCase
      class CreateUser
        def initialize(user_repository)
          @user_repository = user_repository
        end

        def execute(email:, password:)
          return { error: 'Email already exists' } if @user_repository.find_by_email(email)

          password_hash = BCrypt::Password.create(password)
          user = IAM::Domain::Entity::User.new(
            id: SecureRandom.uuid,
            email: email,
            password_hash: password_hash
          )

          @user_repository.save(user)
          user.to_h
        end
      end
    end
  end
end 