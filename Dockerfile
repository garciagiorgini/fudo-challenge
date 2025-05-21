FROM ruby:3.2-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gemas
RUN bundle install

# Copiar el resto de la aplicación
COPY . .

# Crear directorio de logs y dar permisos
RUN mkdir -p /app/log && chmod 777 /app/log

# Exponer el puerto que usará la aplicación
EXPOSE 9292

# Comando para iniciar la aplicación
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0"] 