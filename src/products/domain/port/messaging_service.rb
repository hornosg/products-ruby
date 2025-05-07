module Products
  module Domain
    module Port
      class MessagingService
        def publish_message(queue_name, message)
          raise NotImplementedError
        end
      end
    end
  end
end 