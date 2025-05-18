require 'bcrypt'
require 'jwt'

class Auth
    SECRET = 'ihrefuhwefiouhwiofhfi' # Cambia esto por una clave segura en producción
    @@users = {}
    
    def initialize
       
    end

    def register(req, res)
        body = JSON.parse(req.body.read)
        password_hash = BCrypt::Password.create(body['password'])
        @@users[body['user']] = password_hash
        res.write({ message: 'Usuario registrado' }.to_json)
    end

    def handle_auth(req, res)
        body = JSON.parse(req.body.read)
        password_hash = @@users[body['user']]
        if password_hash && BCrypt::Password.new(password_hash) == body['password']
            payload = { user: body['user'], exp: (Time.now + 3600).to_i }
            token = JWT.encode(payload, SECRET, 'HS256')
            res.write({ token: token }.to_json)
        else
            res.status = 401
            res.write({ error: 'Unauthorized' }.to_json)
        end
    end

    def authorized?(req)
        auth_header = req.env['HTTP_AUTHORIZATION']
        return false unless auth_header&.start_with?('Bearer ')
        token = auth_header.split(' ').last
        begin
            decoded = JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
            true
        rescue JWT::DecodeError, JWT::ExpiredSignature
            false
        end
    end

    def unauthorized(res)
        res.status = 401
        res.write({ error: 'Unauthorized' }.to_json)
        res.finish
    end
end