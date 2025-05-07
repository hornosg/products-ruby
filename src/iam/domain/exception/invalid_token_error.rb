module IAM
  module Domain
    module Exception
      class InvalidTokenError < StandardError
        def initialize(message = 'Invalid or expired token')
          super(message)
        end
      end
    end
  end
end 