require_relative '../../domain/port/messaging_service'
require_relative '../../application/use_case/process_product_message'

module Products
  module Infrastructure
    module Service
      class MemoryMessagingService < Products::Domain::Port::MessagingService
        def initialize(product_repository = nil)
          @product_repository = product_repository
          @messages = {}
          @process_product_message = Products::Application::UseCase::ProcessProductMessage.new(@product_repository)
          @background_thread = start_background_processor
          puts "Servicio de mensajería inicializado con repositorio: #{@product_repository.inspect}"
        end

        def publish_message(queue_name, message)
          @messages[queue_name] ||= []
          @messages[queue_name] << message
          puts "Mensaje publicado en cola #{queue_name}: #{message}"
          true
        end

        private

        def start_background_processor
          Thread.new do
            puts "Iniciando procesador de mensajes en segundo plano..."
            loop do
              begin
                process_messages
              rescue StandardError => e
                puts "Error en el procesador de mensajes: #{e.message}"
                puts e.backtrace.join("\n")
              end
              sleep 5  # Simular procesamiento asíncrono con un retraso
            end
          end
        end

        def process_messages
          @messages.each do |queue_name, queue|
            next if queue.empty?
            
            message = queue.shift
            puts "Procesando mensaje de cola #{queue_name}: #{message}"
            
            # Si es la cola de productos, procesamos el mensaje con el caso de uso
            if queue_name == 'products_queue'
              process_product_message(message)
            end
          end
        end

        def process_product_message(message)
          begin
            result = @process_product_message.execute(message)
            puts "Resultado del procesamiento del producto: #{result.inspect}"
          rescue StandardError => e
            puts "Error al procesar el mensaje del producto: #{e.message}"
            puts e.backtrace.join("\n")
          end
        end
      end
    end
  end
end 