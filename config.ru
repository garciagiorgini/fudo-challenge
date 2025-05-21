# config.ru
require './app'
require './middleware/auth_middleware'
require './middleware/gzip'

# Configurar logging
use Rack::CommonLogger, $stdout

use AuthMiddleware
use GzipMiddleware
run App.new
