require_relative '../../../test_helper'
require 'src/iam/application/use_case/list_users'
require 'src/iam/domain/entity/user'

module IAM
  module Application
    module UseCase
      class ListUsersTest < Minitest::Test
        def setup
          # Creamos mock para el repositorio
          @user_repository = mock
          @use_case = ListUsers.new(@user_repository)
          
          # Creamos algunos usuarios ficticios para el test
          @user1 = IAM::Domain::Entity::User.new(
            id: 'user-id-1',
            email: 'user1@example.com',
            password_hash: 'hash1',
            created_at: Time.new(2025, 1, 1),
            updated_at: Time.new(2025, 1, 1)
          )
          
          @user2 = IAM::Domain::Entity::User.new(
            id: 'user-id-2',
            email: 'user2@example.com',
            password_hash: 'hash2',
            created_at: Time.new(2025, 1, 2),
            updated_at: Time.new(2025, 1, 2)
          )
        end
        
        def test_execute_list_users_with_default_pagination
          # Configuramos el comportamiento esperado del repositorio
          @user_repository.expects(:list).with(page: 1, per_page: 10).returns([@user1, @user2])
          
          # Ejecutamos el caso de uso
          result = @use_case.execute
          
          # Verificamos que devuelva la lista de usuarios como hashes
          assert_equal 2, result.size
          assert_equal 'user-id-1', result[0][:id]
          assert_equal 'user1@example.com', result[0][:email]
          assert_equal 'user-id-2', result[1][:id]
          assert_equal 'user2@example.com', result[1][:email]
          
          # Verificamos que no incluya los password hashes
          refute_includes result[0], :password_hash
          refute_includes result[1], :password_hash
        end
        
        def test_execute_list_users_with_custom_pagination
          # Configuramos el comportamiento esperado del repositorio con paginación personalizada
          @user_repository.expects(:list).with(page: 2, per_page: 5).returns([@user2])
          
          # Ejecutamos el caso de uso con parámetros de paginación personalizados
          result = @use_case.execute(page: 2, per_page: 5)
          
          # Verificamos que devuelva solo el segundo usuario
          assert_equal 1, result.size
          assert_equal 'user-id-2', result[0][:id]
          assert_equal 'user2@example.com', result[0][:email]
        end
        
        def test_execute_list_users_empty_result
          # Configuramos el comportamiento esperado del repositorio para resultados vacíos
          @user_repository.expects(:list).with(page: 1, per_page: 10).returns([])
          
          # Ejecutamos el caso de uso
          result = @use_case.execute
          
          # Verificamos que devuelva un array vacío
          assert_empty result
        end
      end
    end
  end
end 