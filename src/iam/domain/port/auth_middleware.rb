module IAM
  module Domain
    module Port
      class AuthMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end 