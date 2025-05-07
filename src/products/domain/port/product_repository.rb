module Products
  module Domain
    module Port
      class ProductRepository
        def save(product)
          raise NotImplementedError
        end

        def find_by_id(id)
          raise NotImplementedError
        end

        def all
          raise NotImplementedError
        end
      end
    end
  end
end 