require_relative '../../../test_helper'
require 'src/products/application/use_case/create_product_async'

module Products
  module Application
    module UseCase
      class CreateProductAsyncTest < Minitest::Test
        def setup
          # Creamos un mock del servicio de mensajería
          @messaging_service = mock
          @use_case = CreateProductAsync.new(@messaging_service)
          
          # UUID predecibles para testing
          SecureRandom.stubs(:uuid).returns('test-uuid-1', 'test-uuid-2')
          
          # Tiempo fijo para testing
          @fixed_time = Time.new(2025, 1, 1, 12, 0, 0)
          Time.stubs(:now).returns(@fixed_time)
        end
        
        def test_execute_success
          # Configuramos el comportamiento esperado del mock
          @messaging_service.expects(:publish_message)
            .with('products_queue', {
              request_id: 'test-uuid-1',
              operation: 'create_product',
              data: {
                id: 'test-uuid-2',
                name: 'Test Product',
                created_at: @fixed_time.to_s,
                updated_at: @fixed_time.to_s
              }
            }.to_json)
            .returns(true)
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(name: 'Test Product')
          
          # Verificamos los resultados
          assert_equal({ request_id: 'test-uuid-1', product_id: 'test-uuid-2' }, result)
        end
        
        def test_execute_error_handling
          # Configuramos el mock para simular un error
          @messaging_service.expects(:publish_message)
            .raises(StandardError.new('Error de prueba'))
          
          # Ejecutamos el caso de uso
          result = @use_case.execute(name: 'Test Product')
          
          # Verificamos el manejo de errores
          assert_equal "Error al crear producto: Error de prueba", result[:error]
        end
      end
    end
  end
end 