require 'json'

module IAM
  module Infrastructure
    module Controller
      class LoginController
        def initialize(login_use_case)
          @login_use_case = login_use_case
        end

        def login(request)
          begin
            payload = JSON.parse(request.body.read)
            result = @login_use_case.execute(
              email: payload['email'],
              password: payload['password']
            )

            if result && result[:token]
              [200, { 'content-type' => 'application/json' }, [result.to_json]]
            else
              [401, { 'content-type' => 'application/json' }, [{ error: 'Invalid credentials' }.to_json]]
            end
          rescue JSON::ParserError
            [400, { 'content-type' => 'application/json' }, [{ error: 'Invalid JSON' }.to_json]]
          rescue StandardError => e
            [500, { 'content-type' => 'application/json' }, [{ error: e.message }.to_json]]
          end
        end
      end
    end
  end
end 