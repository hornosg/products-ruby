require_relative '../../domain/port/product_repository'

module Products
  module Application
    module UseCase
      class ListProducts
        def initialize(product_repository)
          @product_repository = product_repository
        end

        def execute
          products = @product_repository.all
          products.map(&:to_h)
        end
      end
    end
  end
end 