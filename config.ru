require 'rack'
require_relative 'src/application'

# Configuración para servir el archivo OpenAPI
openapi_handler = lambda do |env|
  headers = {
    'content-type' => 'application/yaml',
    'cache-control' => 'no-store, no-cache, must-revalidate, max-age=0',
    'pragma' => 'no-cache',
    'expires' => '0'
  }
  
  [200, headers, [File.read('openapi.yaml')]]
end

# Configuración para servir el archivo AUTHORS con caché de 24 horas
authors_handler = lambda do |env|
  # Calcular la fecha de expiración 24 horas después
  expire_time = Time.now + 86400 # 24 horas en segundos
  headers = {
    'content-type' => 'text/plain',
    'cache-control' => 'public, max-age=86400',
    'expires' => expire_time.httpdate
  }
  
  [200, headers, [File.read('AUTHORS')]]
end

# Configuración para el endpoint de health check
health_handler = lambda do |env|
  [200, {'content-type' => 'application/json'}, ['{"status":"ok"}']]
end

# Middleware personalizado para manejar Content-Length correctamente con respuestas 204
class CustomContentLength
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, body = @app.call(env)
    
    if status == 204
      # Para respuestas 204, eliminar cualquier encabezado content-length
      headers.delete('content-length')
    else
      # Para otras respuestas, asegurarse de que tengan un content-length correcto
      headers['content-length'] = body.map(&:bytesize).sum.to_s if !headers['content-length'] && body.respond_to?(:map)
    end
    
    [status, headers, body]
  end
end

# Middleware para asegurar que las respuestas 204 no tengan cuerpo
class NoBodyFor204
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, body = @app.call(env)
    
    if status == 204
      # Asegurarse de que el cuerpo de respuesta para 204 sea vacío
      headers.delete('content-type')
      headers.delete('content-length')
      body = []
    end
    
    [status, headers, body]
  end
end

# Aplicación principal que decide a dónde dirigir las solicitudes
app = Rack::Builder.new do
  map '/openapi.yaml' do
    run openapi_handler
  end

  map '/AUTHORS' do
    run authors_handler
  end

  map '/health' do
    run health_handler
  end

  map '/api/v1' do
    use IAM::Infrastructure::Middleware::JWTAuthMiddleware
    # Agregamos el middleware de GZIP para comprimir las respuestas cuando el cliente lo solicite
    use Products::Infrastructure::Middleware::GzipMiddleware
    run Application::API.new
  end

  # Ruta por defecto
  run lambda { |env|
    [404, {'content-type' => 'application/json'}, ['{"error":"Not Found"}']]
  }
end

use Rack::ShowExceptions
use Rack::CommonLogger
# Asegurarse de que las respuestas 204 no tengan encabezados ni cuerpo incorrectos
use NoBodyFor204
# Reemplazamos Rack::ContentLength por nuestro middleware personalizado
use CustomContentLength
run app 