# Fudo Backend Challenge (Rack + Ruby)

Este proyecto implementa una API en Ruby puro usando Rack (sin Rails) como base. Cumple con los requerimientos del challenge de Fudo.

---

## 🧱 Requisitos

- Ubuntu Linux
- Ruby ≥ 3.2
- Bundler (instalado localmente)
- `rack` y `webrick` como gems

---

## 🔧 Instalación paso a paso en Ubuntu

### 1. Instalar Ruby y dependencias de compilación


sudo apt update
sudo apt install ruby-full build-essential

2. Instalar Bundler localmente (sin sudo)

gem install --user-install bundler
Agregá Bundler al PATH en tu ~/.bashrc (ajustá si usás otra shell):


echo 'export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
Reemplazá 3.2.0 con la versión de Ruby que tengas (ruby -v).

📦 Configuración del entorno con Bundler
Configurá Bundler para usar un directorio local:


bundle config set path 'vendor/bundle'
Instalá las dependencias del proyecto:


bundle install
🚀 Cómo ejecutar la app
Una vez instaladas las dependencias, levantá la app con:


bundle exec rackup
La app estará corriendo en:


http://localhost:9292
Si no funciona, asegurate de tener webrick en el Gemfile.

📁 Estructura de archivos

.
├── app.rb              # App principal (Rack)
├── config.ru           # Entrada para rackup
├── product_store.rb    # Lógica de productos
├── auth_service.rb     # Lógica de autenticación
├── middleware/
│   └── gzip.rb         # Middleware de compresión
├── openapi.yaml        # Especificación OpenAPI de la API
├── AUTHORS             # Archivo estático con tu nombre
├── Gemfile             # Dependencias
├── vendor/bundle/      # Gems locales (se genera)
└── README.md
🧪 Probar la API
1. Autenticación


curl -X POST http://localhost:9292/auth \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin", "password":"1234"}'
2. Crear producto

curl -X POST http://localhost:9292/products \
  -H 'Authorization: Bearer token123' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Pizza"}'
3. Consultar productos

curl -X GET http://localhost:9292/products \
  -H 'Authorization: Bearer token123'
📚 Archivos especiales
/openapi.yaml
Documentación OpenAPI de la API.

Se sirve en /openapi.yaml.

No debe ser cacheado (Cache-Control: no-store).

/AUTHORS
Contiene tu nombre y apellido.

Se sirve como archivo estático en la raíz.

Debe ser cacheado por 24 horas (Cache-Control: max-age=86400).

🐳 Docker (opcional)

docker build -t fudo-api .
docker run -p 9292:9292 fudo-api
🧠 Notas
El proyecto no usa base de datos: los productos están en memoria.

El endpoint de creación de producto es asíncrono: el producto aparece a los 5 segundos.

La API devuelve respuestas comprimidas con GZIP si el cliente lo solicita.

🧑 Autores
Ver archivo AUTHORS en la raíz.

yaml


---

¿Querés que también te genere el archivo `AUTHORS` ahora y lo sirvamos desde tu app con cache por 24hs?







