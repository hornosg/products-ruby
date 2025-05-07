require_relative '../../domain/port/product_repository'

module Products
  module Infrastructure
    module Repository
      class MemoryProductRepository < Products::Domain::Port::ProductRepository
        def initialize
          @products = {}
        end

        def save(product)
          @products[product.id] = product
          product
        end

        def find_by_id(id)
          @products[id]
        end

        def all
          @products.values
        end
      end
    end
  end
end 