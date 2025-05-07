require 'rack'
require_relative 'src/application'

# Aplicación principal
class MainApp
  def initialize
    @api = Application::API.new
  end

  def call(env)
    request = Rack::Request.new(env)
    
    if request.path == '/openapi.yaml'
      serve_openapi_yaml
    elsif request.path == '/AUTHORS'
      serve_authors_file
    elsif request.path.start_with?('/api/v1')
      # Eliminar el prefijo /api/v1 y delegar a la API
      env['PATH_INFO'] = env['PATH_INFO'].sub('/api/v1', '')
      @api.call(env)
    else
      [404, {'content-type' => 'application/json'}, ['{"error":"Not Found"}']]
    end
  end

  private

  def serve_openapi_yaml
    headers = {
      'content-type' => 'application/yaml',
      'cache-control' => 'no-store, no-cache, must-revalidate, max-age=0',
      'pragma' => 'no-cache',
      'expires' => '0'
    }
    
    [200, headers, [File.read('openapi.yaml')]]
  end
  
  def serve_authors_file
    # Calcular la fecha de expiración 24 horas después
    expire_time = Time.now + 86400 # 24 horas en segundos
    
    headers = {
      'content-type' => 'text/plain',
      'cache-control' => 'public, max-age=86400',
      'expires' => expire_time.httpdate
    }
    
    [200, headers, [File.read('AUTHORS')]]
  end
end

# Crear la aplicación
app = Rack::Builder.new do
  use IAM::Infrastructure::Middleware::JWTAuthMiddleware
  run MainApp.new
end

# Para ejecutar la aplicación, usa el siguiente comando:
# ruby -run -e httpd . -p 3000
#
# Si ejecutas este archivo directamente, se mostrará esta información
puts "Aplicación Rack lista para ejecutar."
puts "Para iniciar el servidor, ejecuta:"
puts "ruby -run -e httpd . -p 3000" 