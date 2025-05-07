require 'jwt'
require_relative '../../domain/port/auth_service'

module IAM
  module Infrastructure
    module Service
      class JWTAuthService < IAM::Domain::Port::AuthService
        def initialize(secret_key = ENV['JWT_SECRET'] || 'default_secret_key')
          @secret_key = secret_key
        end

        def generate_token(user)
          payload = {
            user_id: user.id,
            email: user.email,
            exp: (Time.now + 24*60*60).to_i  # 24 horas desde ahora
          }
          JWT.encode(payload, @secret_key, 'HS256')
        end

        def verify_token(token)
          decoded = JWT.decode(token, @secret_key, true, { algorithm: 'HS256' })
          decoded[0]
        rescue JWT::DecodeError, JWT::ExpiredSignature
          nil
        end
      end
    end
  end
end 