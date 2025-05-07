require 'jwt'

module IAM
  module Infrastructure
    module Middleware
      class AuthMiddleware
        JWT_SECRET = ENV['JWT_SECRET'] || 'your-secret-key'
        JWT_ALGORITHM = 'HS256'
        TOKEN_EXPIRATION = 3600 # 1 hora en segundos
        REFRESH_THRESHOLD = 300 # 5 minutos en segundos

        def initialize(app)
          @app = app
        end

        def call(env)
          return @app.call(env) if public_path?(env['PATH_INFO'])

          auth_header = env['HTTP_AUTHORIZATION']
          return unauthorized unless auth_header

          token = extract_token(auth_header)
          return unauthorized unless token

          begin
            decoded_token = decode_token(token)
            env['user_id'] = decoded_token['user_id']
            env['token_exp'] = decoded_token['exp']

            # Si el token está próximo a expirar, agregamos un header para refrescar
            if should_refresh?(decoded_token['exp'])
              env['should_refresh_token'] = true
            end

            @app.call(env)
          rescue JWT::DecodeError
            unauthorized
          end
        end

        private

        def public_path?(path)
          ['/api/v1/login', '/api/v1/health'].include?(path)
        end

        def extract_token(auth_header)
          auth_header.split(' ').last if auth_header.start_with?('Bearer ')
        end

        def decode_token(token)
          JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM }).first
        end

        def should_refresh?(exp)
          Time.now.to_i + REFRESH_THRESHOLD >= exp
        end

        def unauthorized
          [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
        end
      end
    end
  end
end 