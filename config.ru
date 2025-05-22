# config.ru
require 'rack'
require './app'
require './middleware/auth_middleware'
require './middleware/gzip'
require_relative './router'

# Configurar logging
use Rack::CommonLogger, $stdout

# Middleware
use AuthMiddleware
use GzipMiddleware

# Run the router
run ROUTER