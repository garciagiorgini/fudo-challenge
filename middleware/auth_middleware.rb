require_relative '../lib/jwt_service'

class AuthMiddleware
  # Rutas que requieren autenticación
  PROTECTED_PATHS = ['/products'].freeze
  
  # Rutas de autenticación que no requieren token
  AUTH_PATHS = ['/auth', '/register', '/refresh'].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    
    # Si es una ruta de autenticación, permitir el acceso
    return @app.call(env) if AUTH_PATHS.any? { |path| req.path.start_with?(path) }
    
    # Verificar si la ruta requiere autenticación
    if PROTECTED_PATHS.any? { |path| req.path.start_with?(path) }
      handle_protected_route(req, env)
    else
      @app.call(env)
    end
  end

  private

  def handle_protected_route(req, env)
    auth_header = req.env['HTTP_AUTHORIZATION']
    
    unless auth_header&.start_with?('Bearer ')
      return unauthorized('Token no proporcionado')
    end

    token = auth_header.split(' ').last
    
    begin
      # Verificar y decodificar el token
      decoded_token = JwtService.verify_token(token)
      
      # Agregar información del usuario al ambiente de la request
      env['jwt.user_id'] = decoded_token['user_id']
      env['jwt.token_type'] = decoded_token['type']
      
      # Continuar con la request
      @app.call(env)
    rescue JwtService::TokenExpiredError
      # Token expirado - el cliente debería usar el refresh token
      return unauthorized(
        'Token expirado',
        401,
        { 'WWW-Authenticate' => 'Bearer error="invalid_token", error_description="Token expirado"' }
      )
    rescue JwtService::SessionExpiredError => e
      # Sesión expirada - el usuario debe volver a iniciar sesión
      return unauthorized(
        e.message,
        401,
        { 'WWW-Authenticate' => 'Bearer error="invalid_token", error_description="Sesión expirada"' }
      )
    rescue JwtService::TokenInvalidError => e
      # Token inválido - error de formato o firma
      return unauthorized(e.message, 401)
    rescue StandardError => e
      # Error inesperado
      return unauthorized('Error de autenticación', 500)
    end
  end

  def unauthorized(message, status = 401, headers = {})
    [
      status,
      { 'Content-Type' => 'application/json' }.merge(headers),
      [{ error: message }.to_json]
    ]
  end
end
