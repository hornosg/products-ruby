require 'securerandom'
require_relative '../domain/entity/product'

module Products
  module Infrastructure
    module Seeds
      def self.run(product_repository)
        # Productos iniciales para pruebas
        products = [
          { name: 'Laptop Pro X1' },
          { name: 'Smartphone Galaxy Z' },
          { name: 'Auriculares Inalámbricos B3' }
        ]

        products.each do |product_data|
          product = Products::Domain::Entity::Product.new(
            id: SecureRandom.uuid,
            name: product_data[:name]
          )
          
          product_repository.save(product)
          puts "Producto seed creado: #{product.to_h}"
        end
      end
    end
  end
end 