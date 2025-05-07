module IAM
  module Domain
    module Port
      class AuthService
        def generate_token(user)
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def verify_token(token)
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end 