require 'zlib'
require 'stringio'

module Products
  module Infrastructure
    module Middleware
      class GzipMiddleware
        # Rutas que no deberían comprimirse (autenticación y usuarios)
        EXCLUDE_PATHS = ['/api/v1/login', '/api/v1/users'].freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          request_path = env['PATH_INFO']
          
          # No comprimir para rutas excluidas
          if EXCLUDE_PATHS.any? { |path| request_path.start_with?(path) }
            return @app.call(env)
          end
          
          status, headers, body = @app.call(env)

          # Solo comprimir si el cliente acepta gzip
          if env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
            # Convertir el body a string si es un array
            response_body = ''
            body.each { |part| response_body += part.to_s }
            
            # Comprimir el body
            compressed_body = StringIO.new
            gz = Zlib::GzipWriter.new(compressed_body)
            gz.write(response_body)
            gz.close
            
            # Actualizar headers y body
            headers['content-encoding'] = 'gzip'
            headers['content-length'] = compressed_body.string.bytesize.to_s
            
            # Devolver la respuesta comprimida
            [status, headers, [compressed_body.string]]
          else
            [status, headers, body]
          end
        end
      end
    end
  end
end 