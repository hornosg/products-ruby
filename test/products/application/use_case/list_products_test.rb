require_relative '../../../test_helper'
require 'src/products/application/use_case/list_products'
require 'src/products/domain/entity/product'

module Products
  module Application
    module UseCase
      class ListProductsTest < Minitest::Test
        def setup
          # Creamos un mock del repositorio de productos
          @product_repository = mock
          @use_case = ListProducts.new(@product_repository)
        end
        
        def test_execute_returns_all_products_as_hash
          # Creamos algunos productos ficticios para el test
          product1 = Products::Domain::Entity::Product.new(
            id: 'prod-1',
            name: 'Producto 1',
            created_at: Time.new(2025, 1, 1),
            updated_at: Time.new(2025, 1, 1)
          )
          
          product2 = Products::Domain::Entity::Product.new(
            id: 'prod-2',
            name: 'Producto 2',
            created_at: Time.new(2025, 1, 2),
            updated_at: Time.new(2025, 1, 2)
          )
          
          # Configuramos el comportamiento esperado del mock
          @product_repository.expects(:all).returns([product1, product2])
          
          # Ejecutamos el caso de uso
          result = @use_case.execute
          
          # Verificamos que el resultado sea un array de hashes con los productos
          assert_equal 2, result.size
          assert_equal 'prod-1', result[0][:id]
          assert_equal 'Producto 1', result[0][:name]
          assert_equal 'prod-2', result[1][:id]
          assert_equal 'Producto 2', result[1][:name]
        end
        
        def test_execute_returns_empty_array_when_no_products
          # Configuramos el mock para devolver una lista vacía
          @product_repository.expects(:all).returns([])
          
          # Ejecutamos el caso de uso
          result = @use_case.execute
          
          # Verificamos que el resultado sea un array vacío
          assert_empty result
        end
      end
    end
  end
end 