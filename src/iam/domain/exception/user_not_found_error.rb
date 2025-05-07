module IAM
  module Domain
    module Exception
      class UserNotFoundError < StandardError
        def initialize(email)
          super("User with email #{email} not found")
        end
      end
    end
  end
end 