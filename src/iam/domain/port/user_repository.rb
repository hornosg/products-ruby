module IAM
  module Domain
    module Port
      class UserRepository
        def find_by_id(id)
          raise NotImplementedError
        end

        def find_by_email(email)
          raise NotImplementedError
        end

        def save(user)
          raise NotImplementedError
        end

        def delete(id)
          raise NotImplementedError
        end

        def list(page: 1, per_page: 10)
          raise NotImplementedError
        end
      end
    end
  end
end 