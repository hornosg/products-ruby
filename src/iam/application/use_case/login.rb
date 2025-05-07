require_relative '../../domain/port/user_repository'
require_relative '../../domain/port/auth_service'

module IAM
  module Application
    module UseCase
      # Definición de excepciones locales
      class UserNotFoundError < StandardError
        def initialize(email)
          super("User not found with email: #{email}")
        end
      end
      
      class AuthenticationError < StandardError
        def initialize
          super("Invalid credentials")
        end
      end
      
      class Login
        def initialize(user_repository, auth_service)
          @user_repository = user_repository
          @auth_service = auth_service
        end

        def execute(email:, password:)
          user = @user_repository.find_by_email(email)
          raise UserNotFoundError.new(email) unless user
          raise AuthenticationError unless user.authenticate(password)

          token = @auth_service.generate_token(user)
          { token: token }
        end
      end
    end
  end
end 