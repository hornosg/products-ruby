require 'securerandom'
require 'json'
require_relative '../../domain/entity/product'

module Products
  module Application
    module UseCase
      class CreateProductAsync
        def initialize(messaging_service)
          @messaging_service = messaging_service
        end

        def execute(name:)
          begin
            request_id = SecureRandom.uuid
            product_id = SecureRandom.uuid
            
            # Preparamos el mensaje con los datos necesarios para crear el producto
            message = {
              request_id: request_id,
              operation: 'create_product',
              data: {
                id: product_id,
                name: name,
                created_at: Time.now.to_s,
                updated_at: Time.now.to_s
              }
            }

            # Publicamos el mensaje en la cola para procesamiento asíncrono
            result = @messaging_service.publish_message('products_queue', message.to_json)
            
            puts "Mensaje enviado a la cola para crear producto '#{name}' con ID #{product_id}: #{result}"
            
            # Devolvemos el ID de la solicitud para que el cliente pueda consultar el estado posteriormente
            { request_id: request_id, product_id: product_id }
          rescue StandardError => e
            puts "Error al crear producto asíncrono: #{e.message}"
            puts e.backtrace.join("\n")
            { error: "Error al crear producto: #{e.message}" }
          end
        end
      end
    end
  end
end 