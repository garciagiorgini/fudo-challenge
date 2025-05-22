# Fudo Backend Challenge (Rack + Ruby)

Este proyecto implementa una API en Ruby puro usando Rack (sin Rails) como base. Cumple con los requerimientos del challenge de Fudo.

---

## 🧱 Requisitos

- Ubuntu Linux
- Ruby ≥ 3.2
- Bundler (instalado localmente)
- Docker y Docker Compose
- `rack` y `webrick` como gems

---

## 🔧 Instalación paso a paso en Ubuntu

### 1. Instalar Ruby y dependencias de compilación

```bash
sudo apt update
sudo apt install ruby-full build-essential
```

### 2. Instalar Bundler localmente (sin sudo)

```bash
gem install --user-install bundler
```

Agregá Bundler al PATH en tu ~/.bashrc (ajustá si usás otra shell):

```bash
echo 'export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Reemplazá 3.2.0 con la versión de Ruby que tengas (ruby -v).

### 3. Configuración del entorno con Bundler

Configurá Bundler para usar un directorio local:

```bash
bundle config set path 'vendor/bundle'
```

Instalá las dependencias del proyecto:

```bash
bundle install
```

## 🚀 Cómo ejecutar la app

### Opción 1: Localmente

Una vez instaladas las dependencias, levantá la app con:

```bash
bundle exec rackup
```

La app estará corriendo en:

http://localhost:9292

### Opción 2: Con Docker

#### Desarrollo (con hot-reload)

1. Crear archivo `.env` con las variables de entorno:
```bash
JWT_SECRET_KEY=tu_clave_secreta_aqui
JWT_TOKEN_EXPIRATION=3600
JWT_REFRESH_TOKEN_EXPIRATION=604800
JWT_MAX_SESSION_DURATION=2592000
```

2. Iniciar con Docker Compose:
```bash
docker compose up
```

#### Producción

1. Construir la imagen:
```bash
docker build -t ruby-challenge .
```

2. Ejecutar el contenedor:
```bash
docker run -p 9292:9292 ruby-challenge
```

## 📁 Estructura de archivos

```
.
├── app.rb              # App principal (Rack)
├── config.ru           # Entrada para rackup
├── router.rb           # Router HTTP con Sinatra
├── product_store.rb    # Lógica de productos
├── auth.rb            # Lógica de autenticación
├── lib/
│   └── jwt_service.rb # Servicio JWT
├── middleware/
│   ├── auth_middleware.rb # Middleware de autenticación
│   └── gzip.rb           # Middleware de compresión
├── config.rb          # Configuración de la app
├── openapi.yaml       # Especificación OpenAPI de la API
├── Gemfile            # Dependencias
├── docker-compose.yml # Configuración de Docker para desarrollo
└── README.md
```

## 🔐 Sistema de Autenticación

La API implementa un sistema de autenticación JWT con refresh tokens:

### Tokens y Tiempos de Expiración

- **Access Token**: Expira después de 1 hora (3600 segundos)
- **Refresh Token**: Expira después de 7 días (604800 segundos)
- **Sesión Máxima**: Expira después de 30 días (2592000 segundos)

### Flujo de Autenticación

1. **Registro de usuario**:
```bash
curl -X POST http://localhost:9292/register \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin", "password":"1234"}'
```

2. **Autenticación**:
```bash
curl -X POST http://localhost:9292/auth \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin", "password":"1234"}'
```
Respuesta:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

3. **Refresh Token**:
```bash
curl -X POST http://localhost:9292/refresh \
  -H 'Content-Type: application/json' \
  -d '{"refresh_token":"tu_refresh_token"}'
```

### Características de Seguridad

- Los tokens incluyen un identificador único (JTI)
- El refresh token mantiene el tiempo de inicio de sesión original
- La sesión expira después de 30 días, independientemente de los refreshes
- Los tokens son firmados con una clave secreta configurable
- En producción, la clave secreta es requerida

## 🛍️ API de Productos

### Crear producto

```bash
curl -X POST http://localhost:9292/products \
  -H 'Authorization: Bearer tu_access_token' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Pizza"}'
```

### Consultar productos

```bash
curl -X GET http://localhost:9292/products \
  -H 'Authorization: Bearer tu_access_token'
```

## 🔐 Variables de Entorno

El proyecto requiere las siguientes variables de entorno:

- `JWT_SECRET_KEY`: Clave secreta para firmar los tokens JWT
- `JWT_TOKEN_EXPIRATION`: Tiempo de expiración del token de acceso (en segundos)
- `JWT_REFRESH_TOKEN_EXPIRATION`: Tiempo de expiración del token de refresco (en segundos)
- `JWT_MAX_SESSION_DURATION`: Tiempo máximo de duración de la sesión (en segundos)

## 🧠 Notas

- El proyecto no usa base de datos: los productos están en memoria
- El endpoint de creación de producto es asíncrono: el producto aparece a los 5 segundos
- La API devuelve respuestas comprimidas con GZIP si el cliente lo solicita
- Los tokens JWT tienen un tiempo de expiración configurable
- Se implementa un sistema de refresh tokens para renovar tokens expirados
- La sesión tiene un tiempo máximo de 30 días, independiente de los refreshes
- El router HTTP está implementado usando Sinatra para un mejor manejo de rutas y errores
- Se incluye logging detallado para facilitar el debugging

## 🐳 Docker

El proyecto está dockerizado para facilitar su despliegue y ejecución. Se proporcionan dos formas de ejecución:

### Desarrollo

Usa Docker Compose para desarrollo con hot-reload:
```bash
docker compose up
```

### Producción

Usa Docker directamente para producción:
```bash
docker build -t ruby-challenge .
docker run -p 9292:9292 ruby-challenge
```

Notas importantes sobre la configuración de Docker:
- Se utiliza Ruby 3.2 con una imagen slim para optimizar el tamaño
- El contenedor está configurado para escuchar en todas las interfaces (0.0.0.0)
- Se han excluido archivos innecesarios mediante `.dockerignore`
- El puerto 9292 está expuesto para acceder a la aplicación
- En desarrollo, se monta el código como volumen para hot-reload
- Las variables de entorno se configuran en el `docker-compose.yml` para desarrollo

🧑 Autores
Ver archivo AUTHORS en la raíz.
