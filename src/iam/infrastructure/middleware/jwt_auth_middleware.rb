require_relative '../../domain/port/auth_middleware'
require_relative '../../domain/port/auth_service'
require_relative '../../domain/exception/invalid_token_error'
require_relative '../service/jwt_auth_service'

module IAM
  module Infrastructure
    module Middleware
      class JWTAuthMiddleware < IAM::Domain::Port::AuthMiddleware
        PUBLIC_PATHS = ['/health', '/api/v1/login', '/openapi.yaml'].freeze
        PUBLIC_ENDPOINTS = { '/api/v1/users' => ['POST'] }.freeze

        def initialize(app, auth_service = IAM::Infrastructure::Service::JWTAuthService.new)
          super(app)
          @auth_service = auth_service
        end

        def call(env)
          request = Rack::Request.new(env)
          return @app.call(env) if public_path?(request.path, request.request_method)

          auth_header = env['HTTP_AUTHORIZATION']
          return unauthorized_response unless auth_header

          token = extract_token(auth_header)
          return unauthorized_response unless token

          begin
            payload = @auth_service.verify_token(token)
            raise IAM::Domain::Exception::InvalidTokenError unless payload

            env['user'] = payload
            @app.call(env)
          rescue IAM::Domain::Exception::InvalidTokenError
            unauthorized_response
          end
        end

        private

        def public_path?(path, method)
          PUBLIC_PATHS.include?(path) || (PUBLIC_ENDPOINTS.key?(path) && PUBLIC_ENDPOINTS[path].include?(method))
        end

        def extract_token(auth_header)
          auth_header.split(' ').last if auth_header.start_with?('Bearer ')
        end

        def unauthorized_response
          [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
        end
      end
    end
  end
end 