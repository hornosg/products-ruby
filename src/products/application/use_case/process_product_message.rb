require 'json'
require 'time'
require_relative '../../domain/entity/product'
require_relative '../../domain/port/product_repository'

module Products
  module Application
    module UseCase
      class ProcessProductMessage
        def initialize(product_repository)
          @product_repository = product_repository
        end

        def execute(message_json)
          begin
            message = JSON.parse(message_json)
            
            case message["operation"]
            when "create_product"
              create_product(message["data"])
            else
              puts "Operación desconocida: #{message["operation"]}"
              { error: "Operación desconocida: #{message["operation"]}" }
            end
          rescue JSON::ParserError => e
            puts "Error al parsear el mensaje JSON: #{e.message}"
            { error: "Error al parsear el mensaje: #{e.message}" }
          rescue StandardError => e
            puts "Error al procesar el mensaje: #{e.message}"
            puts e.backtrace.join("\n")
            { error: "Error al procesar el mensaje: #{e.message}" }
          end
        end

        private

        def create_product(data)
          # Convertimos las fechas a Time si son strings, o usamos el valor actual si no están presentes
          created_at = data["created_at"] ? Time.parse(data["created_at"]) : Time.now
          updated_at = data["updated_at"] ? Time.parse(data["updated_at"]) : Time.now

          product = Products::Domain::Entity::Product.new(
            id: data["id"],
            name: data["name"],
            created_at: created_at,
            updated_at: updated_at
          )
          
          saved_product = @product_repository.save(product)
          puts "Producto guardado en la base de datos: #{saved_product.to_h}"
          
          { product: saved_product.to_h, status: "created" }
        end
      end
    end
  end
end 