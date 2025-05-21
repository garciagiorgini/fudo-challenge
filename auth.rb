require 'bcrypt'
require_relative './lib/jwt_service'
require_relative './config'

class Auth
    @@users = {}
    
    def initialize
    end

    def register(req, res)
        begin
            puts "=== INICIO REGISTER ==="
            body = JSON.parse(req.body.read)
            puts "Body recibido en register: #{body.inspect}"
            STDERR.puts "Body recibido en register: #{body.inspect}"
            # Validaciones básicas
            user = body['user'].to_s
            password = body['password'].to_s
            puts "User: #{user.inspect}"
            puts "Password: #{password.inspect}"
            
            if user.empty? || password.empty?
                res.status = 400
                return res.write({ error: 'Usuario y contraseña son requeridos' }.to_json)
            end

            # Validación de contraseña
            puts "Longitud password: #{password.length}"
            puts "PASSWORD_MIN_LENGTH: #{Config::PASSWORD_MIN_LENGTH.inspect}"
            if password.length < Config::PASSWORD_MIN_LENGTH
                res.status = 400
                return res.write({ error: "La contraseña debe tener al menos #{Config::PASSWORD_MIN_LENGTH} caracteres" }.to_json)
            end

            if @@users[user]
                res.status = 409
                return res.write({ error: 'Usuario ya existe' }.to_json)
            end

            password_hash = BCrypt::Password.create(password)
            @@users[user] = {
                password_hash: password_hash,
                created_at: Time.now,
                login_attempts: 0,
                last_login_attempt: nil
            }
            
            puts "=== FIN REGISTER ==="
            res.write({ message: 'Usuario registrado exitosamente' }.to_json)
        rescue => e
            puts "ERROR EN REGISTER: #{e.message}"
            puts "Backtrace: #{e.backtrace.join("\n")}"
            res.status = 500
            res.write({ error: 'Error interno del servidor', details: e.message }.to_json)
        end
    end

    def handle_auth(req, res)
        body = JSON.parse(req.body.read)
        user_data = @@users[body['user']]
        
        if user_data
            # Verificar intentos de login
            if user_data[:login_attempts] >= 5 && 
               user_data[:last_login_attempt] && 
               Time.now - user_data[:last_login_attempt] < 300 # 5 minutos
                res.status = 429
                return res.write({ error: 'Demasiados intentos fallidos. Intente más tarde.' }.to_json)
            end

            if BCrypt::Password.new(user_data[:password_hash]) == body['password']
                # Resetear intentos de login
                user_data[:login_attempts] = 0
                user_data[:last_login_attempt] = nil
                
                tokens = JwtService.generate_tokens(body['user'])
                res.write(tokens.to_json)
            else
                # Incrementar intentos fallidos
                user_data[:login_attempts] += 1
                user_data[:last_login_attempt] = Time.now
                
                res.status = 401
                res.write({ error: 'Credenciales inválidas' }.to_json)
            end
        else
            res.status = 401
            res.write({ error: 'Credenciales inválidas' }.to_json)
        end
    end

    def refresh_token(req, res)
        body = JSON.parse(req.body.read)
        refresh_token = body['refresh_token']

        if refresh_token.nil?
            res.status = 400
            return res.write({ error: 'Refresh token es requerido' }.to_json)
        end

        begin
            tokens = JwtService.refresh_token(refresh_token)
            res.write(tokens.to_json)
        rescue JwtService::TokenError => e
            res.status = 401
            res.write({ error: e.message }.to_json)
        end
    end

    def authorized?(req)
        auth_header = req.env['HTTP_AUTHORIZATION']
        return false unless auth_header&.start_with?('Bearer ')
        token = auth_header.split(' ').last
        begin
            decoded = JWT.decode(token, Config::JWT::SECRET_KEY, true, { 
                algorithm: Config::JWT::ALGORITHM 
            })
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