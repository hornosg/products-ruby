require 'bcrypt'

module IAM
  module Domain
    module Entity
      class User
        attr_reader :id, :email, :password_hash, :created_at, :updated_at

        def initialize(email:, password_hash:, id: nil, created_at: Time.now, updated_at: Time.now)
          @id = id
          @email = email
          @password_hash = password_hash
          @created_at = created_at
          @updated_at = updated_at
        end

        def authenticate(password)
          BCrypt::Password.new(@password_hash) == password
        end

        def to_h
          {
            id: id,
            email: email,
            created_at: created_at,
            updated_at: updated_at
          }
        end
      end
    end
  end
end 