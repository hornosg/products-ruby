# API Ruby con Arquitectura Hexagonal

Esta es una API REST construida en Ruby siguiendo los principios de la Arquitectura Hexagonal (también conocida como Ports and Adapters).

## Requisitos Previos

- Ruby 3.3.0 o superior
- Bundler

## Instalación

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd products-ruby
```

2. Instalar las dependencias:
```bash
bundle install
```

## Configuración

La aplicación utiliza variables de entorno para la configuración. Por defecto, se utiliza una clave secreta para JWT, pero es recomendable configurarla en producción:

```bash
export JWT_SECRET=tu-clave-secreta-muy-segura
```

## Ejecución

Para iniciar el servidor en modo desarrollo:

```bash
rackup -p 3000
```

El servidor se iniciará en `http://localhost:3000`

## Usuario Inicial

Al iniciar la aplicación, se crea automáticamente un usuario administrador con las siguientes credenciales:
- Email: `admin@example.com`
- Password: `admin123`

Este usuario se crea mediante un seed que se ejecuta al iniciar la aplicación. Las contraseñas se almacenan de forma segura usando BCrypt para el hashing.

## Tests Unitarios

El proyecto incluye tests unitarios para los casos de uso. Para ejecutar los tests:

```bash
bundle exec rake test
```

El proyecto cuenta con **16 tests** y **64 aserciones** que cubren los casos de uso de los módulos IAM y Products.

Los tests utilizan:
- **Minitest**: Como framework de testing
- **Mocha**: Para mocking y stubbing
- **Minitest-reporters**: Para informes de tests con formato mejorado

### Cobertura de Tests

Los tests unitarios cubren:
- ✅ Login y autenticación
- ✅ Creación de usuarios
- ✅ Listado de usuarios
- ✅ Procesamiento asíncrono de productos
- ✅ Creación de productos
- ✅ Listado de productos
- ✅ Manejo de errores en todos los casos

### Estructura de los Tests

Los tests siguen la misma estructura de la aplicación:

```
test/
├── iam/
│   └── application/
│       └── use_case/
│           ├── create_user_test.rb
│           ├── list_users_test.rb
│           └── login_test.rb
├── products/
│   └── application/
│       └── use_case/
│           ├── create_product_async_test.rb
│           ├── list_products_test.rb
│           └── process_product_message_test.rb
└── test_helper.rb
```

### Ejecutar Tests Específicos

Para ejecutar un test específico:

```bash
bundle exec ruby -Ilib:test test/iam/application/use_case/login_test.rb
```

Para ejecutar un método de test específico:

```bash
bundle exec ruby -Ilib:test test/iam/application/use_case/login_test.rb -n test_execute_successful_login
```

## Endpoints Disponibles

### 1. Health Check
```bash
curl http://localhost:3000/health
```
Respuesta esperada:
```json
{"status":"ok"}
```

### 2. Crear Usuario
```bash
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "contraseña123"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```
Respuesta esperada:
```json
{"token":"eyJhbGciOiJIUzI1NiJ9..."}
```

### 4. Acceder a Rutas Protegidas
```bash
curl http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer <token-recibido-en-login>"
```

### 5. Crear Producto (Asíncrono)
```bash
curl -X POST http://localhost:3000/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token-recibido-en-login>" \
  -d '{
    "name": "Producto Ejemplo"
  }'
```

### 6. Listar Productos
```bash
curl http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer <token-recibido-en-login>"
```

## Colección Postman

Para facilitar las pruebas, se incluye una colección de Postman en el archivo `productos-api.postman_collection.json`. Esta colección incluye todos los endpoints disponibles con ejemplos de solicitudes configuradas.

Para importar la colección:
1. Abrir Postman
2. Hacer clic en "Import"
3. Seleccionar el archivo `productos-api.postman_collection.json`
4. También importar el archivo `productos-api.postman_environment.json` para tener las variables de entorno configuradas

## Documentación OpenAPI

La API está documentada con OpenAPI 3.0. Puedes acceder a la especificación en:
```
http://localhost:3000/openapi.yaml
```

## Estructura del Proyecto

```
.
├── src/
│   ├── iam/
│   │   ├── application/    # Casos de uso y servicios de aplicación
│   │   ├── domain/        # Entidades y reglas de negocio
│   │   └── infrastructure/# Implementaciones concretas (repositorios, etc.)
│   └── products/
│       ├── application/    # Casos de uso y servicios de aplicación
│       ├── domain/        # Entidades y reglas de negocio
│       └── infrastructure/# Implementaciones concretas (repositorios, etc.)
├── config/
│   └── config.ru          # Configuración de Rack
├── test/                 # Tests unitarios
├── Gemfile
└── README.md
```

## Características Implementadas

- ✅ Arquitectura Hexagonal
- ✅ Autenticación con JWT
- ✅ Middleware de autenticación
- ✅ Gestión de usuarios
- ✅ Endpoint de salud
- ✅ Hashing seguro de contraseñas con BCrypt
- ✅ Usuario inicial automático
- ✅ Módulo de Productos
- ✅ Procesamiento asíncrono de peticiones
- ✅ Compresión GZIP para respuestas
- ✅ Documentación de API con OpenAPI
- ✅ Tests unitarios para casos de uso

## Próximas Características

- [ ] Persistencia en base de datos
- [ ] Tests automatizados de integración
- [ ] Sistema de logs
- [ ] Manejo de errores mejorado 