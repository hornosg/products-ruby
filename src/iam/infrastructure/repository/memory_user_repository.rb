module IAM
  module Infrastructure
    module Repository
      class MemoryUserRepository < Domain::Port::UserRepository
        def initialize
          @users = {}
          @email_index = {}
        end

        def find_by_id(id)
          @users[id]
        end

        def find_by_email(email)
          id = @email_index[email]
          puts "Buscando usuario con email: #{email}, ID encontrado: #{id.inspect}"
          id ? @users[id] : nil
        end

        def save(user)
          puts "Guardando usuario: #{user.inspect}"
          @users[user.id] = user
          @email_index[user.email] = user.id
          puts "Usuarios en memoria: #{@users.keys.inspect}"
          puts "Índice de emails: #{@email_index.inspect}"
          user
        end

        def delete(id)
          user = @users[id]
          if user
            @email_index.delete(user.email)
            @users.delete(id)
          end
        end

        def list(page: 1, per_page: 10)
          start_idx = (page - 1) * per_page
          end_idx = start_idx + per_page
          @users.values[start_idx...end_idx] || []
        end
      end
    end
  end
end 