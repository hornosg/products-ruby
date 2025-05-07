module Products
  module Domain
    module Entity
      class Product
        attr_reader :id, :name, :created_at, :updated_at

        def initialize(name:, id: nil, created_at: Time.now, updated_at: Time.now)
          @id = id
          @name = name
          @created_at = created_at
          @updated_at = updated_at
        end

        def to_h
          {
            id: id,
            name: name,
            created_at: created_at,
            updated_at: updated_at
          }
        end
      end
    end
  end
end 