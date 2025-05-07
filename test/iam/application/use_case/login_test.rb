require_relative '../../../test_helper'
require 'src/iam/application/use_case/login'
require 'src/iam/domain/entity/user'

module IAM
  module Application
    module UseCase
      class LoginTest < Minitest::Test
        def setup
          # Creamos mocks para los servicios
          @user_repository = mock
          @auth_service = mock
          @use_case = Login.new(@user_repository, @auth_service)
          
          # Datos de prueba
          @email = 'test@example.com'
          @password = 'password123'
          @token = 'test-token-123'
          
          # Creamos un usuario de prueba con contraseña hasheada
          @password_hash = BCrypt::Password.create(@password)
          @user = IAM::Domain::Entity::User.new(
            id: 'test-user-id',
            email: @email,
            password_hash: @password_hash
          )
        end
        
        def test_execute_successful_login
          # Configuramos el comportamiento esperado del repositorio
          @user_repository.expects(:find_by_email).with(@email).returns(@user)
          
          # Configuramos el comportamiento esperado del servicio de autenticación
          @auth_service.expects(:generate_token).with(@user).returns(@token)
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(email: @email, password: @password)
          
          # Verificamos que devuelva el token esperado
          assert_equal({ token: @token }, result)
        end
        
        def test_execute_user_not_found
          # Configuramos el comportamiento esperado para un usuario no encontrado
          @user_repository.expects(:find_by_email).with(@email).returns(nil)
          
          # Verificamos que se lance la excepción correcta
          error = assert_raises(IAM::Application::UseCase::UserNotFoundError) do
            @use_case.execute(email: @email, password: @password)
          end
          
          assert_equal "User not found with email: #{@email}", error.message
        end
        
        def test_execute_invalid_password
          # Configuramos el comportamiento esperado del repositorio
          @user_repository.expects(:find_by_email).with(@email).returns(@user)
          
          # Verificamos que se lance la excepción correcta con contraseña incorrecta
          error = assert_raises(IAM::Application::UseCase::AuthenticationError) do
            @use_case.execute(email: @email, password: 'wrong_password')
          end
          
          assert_equal "Invalid credentials", error.message
        end
      end
    end
  end
end 