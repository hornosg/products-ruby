require 'json'

module Products
  module Infrastructure
    module Controller
      class ProductsController
        def initialize(create_product_async_use_case, list_products_use_case = nil)
          @create_product_async_use_case = create_product_async_use_case
          @list_products_use_case = list_products_use_case
        end

        def create_async(request)
          begin
            payload = JSON.parse(request.body.read)
            
            # Validar los datos de entrada
            unless payload['name'] && !payload['name'].strip.empty?
              return [422, { 'content-type' => 'application/json' }, [{ error: 'El nombre del producto es requerido' }.to_json]]
            end

            # Ejecutar el caso de uso para crear el producto asíncronamente
            result = @create_product_async_use_case.execute(
              name: payload['name']
            )

            # Devolver una respuesta indicando que la solicitud se procesará asíncronamente
            [202, { 'content-type' => 'application/json' }, [{ 
              message: 'Su solicitud se procesará asíncronamente',
              request_id: result[:request_id]
            }.to_json]]
          rescue JSON::ParserError
            [400, { 'content-type' => 'application/json' }, [{ error: 'JSON inválido' }.to_json]]
          rescue StandardError => e
            [500, { 'content-type' => 'application/json' }, [{ error: e.message }.to_json]]
          end
        end

        def list(request)
          begin
            result = @list_products_use_case.execute
            [200, { 'content-type' => 'application/json' }, [{ products: result }.to_json]]
          rescue StandardError => e
            [500, { 'content-type' => 'application/json' }, [{ error: e.message }.to_json]]
          end
        end
      end
    end
  end
end 