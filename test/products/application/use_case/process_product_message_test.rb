require_relative '../../../test_helper'
require 'src/products/application/use_case/process_product_message'
require 'src/products/domain/entity/product'
require 'json'
require 'time'

module Products
  module Application
    module UseCase
      class ProcessProductMessageTest < Minitest::Test
        def setup
          # Creamos un mock del repositorio de productos
          @product_repository = mock
          @use_case = ProcessProductMessage.new(@product_repository)
        end
        
        def test_execute_create_product_success
          # Datos de prueba
          product_id = 'test-product-id'
          created_at = Time.new(2025, 1, 1, 12, 0, 0)
          updated_at = Time.new(2025, 1, 1, 12, 0, 0)
          
          # Mensaje JSON para la creación de un producto
          message = {
            operation: 'create_product',
            data: {
              id: product_id,
              name: 'Test Product',
              created_at: created_at.to_s,
              updated_at: updated_at.to_s
            }
          }.to_json
          
          # Creamos un objeto producto esperado
          expected_product = Products::Domain::Entity::Product.new(
            id: product_id,
            name: 'Test Product',
            created_at: created_at,
            updated_at: updated_at
          )
          
          # Configuramos el mock para esperar la llamada a save con un producto similar
          @product_repository.expects(:save).with do |product|
            product.id == product_id &&
            product.name == 'Test Product' &&
            product.created_at.to_s == created_at.to_s &&
            product.updated_at.to_s == updated_at.to_s
          end.returns(expected_product)
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(message)
          
          # Verificamos el resultado
          assert_equal 'created', result[:status]
          assert_equal product_id, result[:product][:id]
          assert_equal 'Test Product', result[:product][:name]
        end
        
        def test_execute_unknown_operation
          # Mensaje con operación desconocida
          message = {
            operation: 'unknown_operation',
            data: {}
          }.to_json
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(message)
          
          # Verificamos que se maneje correctamente
          assert_equal "Operación desconocida: unknown_operation", result[:error]
        end
        
        def test_execute_invalid_json
          # Mensaje JSON inválido
          invalid_message = '{ "operation": "create_product", invalid_json'
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(invalid_message)
          
          # Verificamos que se maneje el error de parsing
          assert_match /Error al parsear el mensaje/, result[:error]
        end
        
        def test_execute_general_error_handling
          # Mensaje válido
          message = {
            operation: 'create_product',
            data: {
              id: 'test-id',
              name: 'Test Product'
            }
          }.to_json
          
          # Configuramos el mock para lanzar un error
          @product_repository.expects(:save).raises(StandardError.new('Error de prueba'))
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(message)
          
          # Verificamos el manejo de errores generales
          assert_match /Error al procesar el mensaje/, result[:error]
        end
      end
    end
  end
end 