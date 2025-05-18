require 'jwt'

class AuthMiddleware
  SECRET = 'ihrefuhwefiouhwiofhfi'

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    # Proteger solo rutas que empiezan con /products
    if req.path.start_with?('/products')
      auth_header = req.env['HTTP_AUTHORIZATION']
      unless auth_header&.start_with?('Bearer ')
        return unauthorized
      end
      token = auth_header.split(' ').last
      begin
        JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
      rescue JWT::DecodeError, JWT::ExpiredSignature
        return unauthorized
      end
    end
    @app.call(env)
  end

  def unauthorized
    [
      401,
      { 'Content-Type' => 'application/json' },
      [ { error: 'Unauthorized' }.to_json ]
    ]
  end
end
