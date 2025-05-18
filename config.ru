# config.ru
require './app'
require './middleware/auth_middleware'
require './middleware/gzip'

use AuthMiddleware
use GzipMiddleware
run App.new
