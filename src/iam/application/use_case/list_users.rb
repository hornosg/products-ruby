require_relative '../../domain/port/user_repository'

module IAM
  module Application
    module UseCase
      class ListUsers
        def initialize(user_repository)
          @user_repository = user_repository
        end

        def execute(page: 1, per_page: 10)
          users = @user_repository.list(page: page, per_page: per_page)
          users.map(&:to_h)
        end
      end
    end
  end
end 