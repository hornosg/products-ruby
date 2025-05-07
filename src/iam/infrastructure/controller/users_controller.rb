require 'json'

module IAM
  module Infrastructure
    module Controller
      class UsersController
        def initialize(create_user_use_case, list_users_use_case = nil)
          @create_user_use_case = create_user_use_case
          @list_users_use_case = list_users_use_case
        end

        def create(request)
          begin
            payload = JSON.parse(request.body.read)
            result = @create_user_use_case.execute(
              email: payload['email'],
              password: payload['password']
            )

            if result.key?(:error)
              [422, { 'content-type' => 'application/json' }, [result.to_json]]
            else
              [204, {}, []]
            end
          rescue JSON::ParserError
            [400, { 'content-type' => 'application/json' }, [{ error: 'Invalid JSON' }.to_json]]
          rescue StandardError => e
            [500, { 'content-type' => 'application/json' }, [{ error: e.message }.to_json]]
          end
        end

        def list(request)
          begin
            page = (request.params['page'] || 1).to_i
            per_page = (request.params['per_page'] || 10).to_i

            result = @list_users_use_case.execute(page: page, per_page: per_page)
            [200, { 'content-type' => 'application/json' }, [{ users: result }.to_json]]
          rescue StandardError => e
            [500, { 'content-type' => 'application/json' }, [{ error: e.message }.to_json]]
          end
        end
      end
    end
  end
end 