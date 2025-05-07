require_relative '../../../test_helper'
require 'src/iam/application/use_case/create_user'
require 'src/iam/domain/entity/user'

module IAM
  module Application
    module UseCase
      class CreateUserTest < Minitest::Test
        def setup
          # Creamos mock para el repositorio
          @user_repository = mock
          @use_case = CreateUser.new(@user_repository)
          
          # Datos de prueba
          @email = 'new_user@example.com'
          @password = 'secure_password123'
          
          # Simular UUID predecible para el test
          @user_id = 'test-user-id-123'
          SecureRandom.stubs(:uuid).returns(@user_id)
          
          # Tiempo fijo para testing
          @fixed_time = Time.new(2025, 1, 1, 12, 0, 0)
          Time.stubs(:now).returns(@fixed_time)
        end
        
        def test_execute_successful_user_creation
          # Configuramos el comportamiento esperado del repositorio (usuario no existe)
          @user_repository.expects(:find_by_email).with(@email).returns(nil)
          
          # BCrypt generará un hash aleatorio, así que no podemos predecir el valor exacto
          # Capturaremos el usuario que se intenta guardar para verificar sus propiedades
          @user_repository.expects(:save).with do |user|
            assert_equal @user_id, user.id
            assert_equal @email, user.email
            # El password_hash es de tipo BCrypt::Password o String dependiendo de la versión
            assert_match(/^\$2a\$/, user.password_hash.to_s)
            assert BCrypt::Password.new(user.password_hash.to_s) == @password
            true # Devolvemos true para que el matching funcione
          end.returns(IAM::Domain::Entity::User.new(
            id: @user_id,
            email: @email,
            password_hash: BCrypt::Password.create(@password),
            created_at: @fixed_time,
            updated_at: @fixed_time
          ))
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(email: @email, password: @password)
          
          # Verificamos el resultado (el to_h del usuario)
          assert_equal @user_id, result[:id]
          assert_equal @email, result[:email]
          assert_equal @fixed_time, result[:created_at]
          assert_equal @fixed_time, result[:updated_at]
          refute_includes result, :password_hash # Verificamos que no incluya el hash en la respuesta
        end
        
        def test_execute_email_already_exists
          # Simulamos que el usuario ya existe
          existing_user = IAM::Domain::Entity::User.new(
            id: 'existing-id',
            email: @email,
            password_hash: 'some-hash'
          )
          
          # Configuramos el comportamiento esperado
          @user_repository.expects(:find_by_email).with(@email).returns(existing_user)
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(email: @email, password: @password)
          
          # Verificamos que devuelva un error
          assert_equal({ error: 'Email already exists' }, result)
        end
      end
    end
  end
end 