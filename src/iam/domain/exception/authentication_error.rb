module IAM
  module Domain
    module Exception
      class AuthenticationError < StandardError
        def initialize(message = 'Invalid credentials')
          super(message)
        end
      end
    end
  end
end 