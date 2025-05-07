require 'rack'
require 'json'
require_relative 'iam/domain/entity/user'
require_relative 'iam/domain/port/user_repository'
require_relative 'iam/domain/port/auth_service'
require_relative 'iam/application/use_case/create_user'
require_relative 'iam/application/use_case/login'
require_relative 'iam/application/use_case/list_users'
require_relative 'iam/infrastructure/repository/memory_user_repository'
require_relative 'iam/infrastructure/service/jwt_auth_service'
require_relative 'iam/infrastructure/controller/users_controller'
require_relative 'iam/infrastructure/controller/login_controller'
require_relative 'iam/infrastructure/middleware/jwt_auth_middleware'
require_relative 'iam/infrastructure/seeds'

# Nuevos imports para productos
require_relative 'products/domain/entity/product'
require_relative 'products/domain/port/product_repository'
require_relative 'products/domain/port/messaging_service'
require_relative 'products/application/use_case/create_product_async'
require_relative 'products/application/use_case/list_products'
require_relative 'products/infrastructure/repository/memory_product_repository'
require_relative 'products/infrastructure/service/memory_messaging_service'
require_relative 'products/infrastructure/controller/products_controller'
require_relative 'products/infrastructure/middleware/gzip_middleware'
require_relative 'products/infrastructure/seeds'

module Application
  # Repositorio compartido para todos los usuarios
  USER_REPOSITORY = IAM::Infrastructure::Repository::MemoryUserRepository.new
  
  # Repositorio compartido para todos los productos
  PRODUCT_REPOSITORY = Products::Infrastructure::Repository::MemoryProductRepository.new
  
  # Inicializar seeds (una sola vez)
  IAM::Infrastructure::Seeds.run(USER_REPOSITORY)
  Products::Infrastructure::Seeds.run(PRODUCT_REPOSITORY)
  
  class API
    def initialize
      setup_iam
      setup_products
    end

    def setup_iam
      # Inicializar servicios de infraestructura
      @user_repository = Application::USER_REPOSITORY
      @auth_service = IAM::Infrastructure::Service::JWTAuthService.new

      # Inicializar casos de uso con inyección de dependencias
      @create_user_use_case = IAM::Application::UseCase::CreateUser.new(@user_repository)
      @login_use_case = IAM::Application::UseCase::Login.new(@user_repository, @auth_service)
      @list_users_use_case = IAM::Application::UseCase::ListUsers.new(@user_repository)

      # Inicializar controladores
      @users_controller = IAM::Infrastructure::Controller::UsersController.new(@create_user_use_case, @list_users_use_case)
      @login_controller = IAM::Infrastructure::Controller::LoginController.new(@login_use_case)
    end

    def setup_products
      # Inicializar servicios de infraestructura
      @product_repository = Application::PRODUCT_REPOSITORY
      @messaging_service = Products::Infrastructure::Service::MemoryMessagingService.new(@product_repository)

      # Inicializar casos de uso con inyección de dependencias
      @create_product_async_use_case = Products::Application::UseCase::CreateProductAsync.new(@messaging_service)
      @list_products_use_case = Products::Application::UseCase::ListProducts.new(@product_repository)

      # Inicializar controladores
      @products_controller = Products::Infrastructure::Controller::ProductsController.new(@create_product_async_use_case, @list_products_use_case)
    end

    def call(env)
      request = Rack::Request.new(env)
      
      case request.path
      when '/api/v1/users'
        case request.request_method
        when 'POST'
          @users_controller.create(request)
        when 'GET'
          @users_controller.list(request)
        else
          [405, { 'content-type' => 'application/json' }, [{ error: 'Method not allowed' }.to_json]]
        end
      when '/api/v1/login'
        case request.request_method
        when 'POST'
          @login_controller.login(request)
        else
          [405, { 'content-type' => 'application/json' }, [{ error: 'Method not allowed' }.to_json]]
        end
      when '/api/v1/products'
        case request.request_method
        when 'POST'
          @products_controller.create_async(request)
        when 'GET'
          @products_controller.list(request)
        else
          [405, { 'content-type' => 'application/json' }, [{ error: 'Method not allowed' }.to_json]]
        end
      when '/health'
        [200, { 'content-type' => 'application/json' }, [{ status: 'ok' }.to_json]]
      else
        [404, { 'content-type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
      end
    end
  end
end 