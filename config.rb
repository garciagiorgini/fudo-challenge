require 'dotenv'

# Cargar variables de entorno desde .env
Dotenv.load

module Config
  # Constantes de entorno
  ENV = ENV['APP_ENV'] || 'development'
  DEVELOPMENT = ENV == 'development'
  PRODUCTION = ENV == 'production'
  TEST = ENV == 'test'
  PASSWORD_MIN_LENGTH = (ENV['PASSWORD_MIN_LENGTH'] || 8).to_i

  module JWT
    SECRET_KEY = if PRODUCTION
                   ENV['JWT_SECRET_KEY'] || raise('JWT_SECRET_KEY es requerido en producción')
                 else
                   ENV['JWT_SECRET_KEY'] || 'clave_secreta_por_defecto_no_usar_en_produccion'
                 end
    ALGORITHM = 'HS256'.freeze
    TOKEN_EXPIRATION = (ENV['JWT_TOKEN_EXPIRATION'] || 3600).to_i # 1 hora por defecto
    REFRESH_TOKEN_EXPIRATION = (ENV['JWT_REFRESH_TOKEN_EXPIRATION'] || 604800).to_i # 7 días por defecto
    MAX_SESSION_DURATION = (ENV['JWT_MAX_SESSION_DURATION'] || 2592000).to_i # 30 días por defecto
  end
end 