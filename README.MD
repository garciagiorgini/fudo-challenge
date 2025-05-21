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
├── product_store.rb    # Lógica de productos
├── auth.rb            # Lógica de autenticación
├── lib/
│   └── jwt_service.rb # Servicio JWT
├── middleware/
│   └── auth_middleware.rb # Middleware de autenticación
├── config.rb          # Configuración de la app
├── openapi.yaml       # Especificación OpenAPI de la API
├── Gemfile            # Dependencias
├── docker-compose.yml # Configuración de Docker para desarrollo
└── README.md
```

## 🧪 Probar la API

### 1. Registro de usuario

```bash
curl -X POST http://localhost:9292/register \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin", "password":"1234"}'
```

### 2. Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin", "password":"1234"}'
```

### 3. Refresh Token

```bash
curl -X POST http://localhost:9292/refresh \
  -H 'Content-Type: application/json' \
  -d '{"refresh_token":"tu_refresh_token"}'
```

### 4. Crear producto

```bash
curl -X POST http://localhost:9292/products \
  -H 'Authorization: Bearer tu_access_token' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Pizza"}'
```

### 5. Consultar productos

```bash
curl -X GET http://localhost:9292/products \
  -H 'Authorization: Bearer tu_access_token'
```

## 🔐 Variables de Entorno

El proyecto requiere las siguientes variables de entorno:

- `JWT_SECRET_KEY`: Clave secreta para firmar los tokens JWT
- `JWT_TOKEN_EXPIRATION`: Tiempo de expiración del token de acceso (en segundos)
- `JWT_REFRESH_TOKEN_EXPIRATION`: Tiempo de expiración del token de refresco (en segundos)

## 🧠 Notas

- El proyecto no usa base de datos: los productos están en memoria
- El endpoint de creación de producto es asíncrono: el producto aparece a los 5 segundos
- La API devuelve respuestas comprimidas con GZIP si el cliente lo solicita
- Los tokens JWT tienen un tiempo de expiración configurable
- Se implementa un sistema de refresh tokens para renovar tokens expirados

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

yaml
