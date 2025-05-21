require 'jwt'
require 'openssl'
require 'securerandom'
require_relative '../config'

class JwtService
  class TokenError < StandardError; end
  class TokenExpiredError < TokenError; end
  class TokenInvalidError < TokenError; end

  def self.generate_tokens(user_id)
    access_token = generate_access_token(user_id)
    refresh_token = generate_refresh_token(user_id)
    
    {
      access_token: access_token,
      refresh_token: refresh_token,
      token_type: 'Bearer',
      expires_in: Config::JWT::TOKEN_EXPIRATION
    }
  end

  def self.verify_token(token)
    decoded_token = decode_token(token)
    validate_token_claims(decoded_token)
    decoded_token
  rescue JWT::ExpiredSignature
    raise TokenExpiredError, 'Token expirado'
  rescue JWT::DecodeError
    raise TokenInvalidError, 'Token inválido'
  end

  def self.refresh_token(refresh_token)
    decoded_token = decode_token(refresh_token)
    validate_refresh_token(decoded_token)
    generate_tokens(decoded_token['user_id'])
  end

  private

  def self.generate_access_token(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + Config::JWT::TOKEN_EXPIRATION,
      iat: Time.now.to_i,
      type: 'access',
      jti: SecureRandom.uuid # Identificador único del token
    }
    encode_token(payload)
  end

  def self.generate_refresh_token(user_id)
    payload = {
      user_id: user_id,
      exp: Time.now.to_i + Config::JWT::REFRESH_TOKEN_EXPIRATION,
      iat: Time.now.to_i,
      type: 'refresh',
      jti: SecureRandom.uuid # Identificador único del token
    }
    encode_token(payload)
  end

  def self.encode_token(payload)
    JWT.encode(payload, Config::JWT::SECRET_KEY, Config::JWT::ALGORITHM)
  end

  def self.decode_token(token)
    JWT.decode(token, Config::JWT::SECRET_KEY, true, {
      algorithm: Config::JWT::ALGORITHM,
      verify_iat: true,
      verify_jti: true
    }).first
  end

  def self.validate_token_claims(decoded_token)
    raise TokenInvalidError, 'Token type inválido' unless decoded_token['type'] == 'access'
    raise TokenInvalidError, 'Token expirado' if Time.now.to_i > decoded_token['exp']
    raise TokenInvalidError, 'Token emitido en el futuro' if Time.now.to_i < decoded_token['iat']
  end

  def self.validate_refresh_token(decoded_token)
    raise TokenInvalidError, 'Token type inválido' unless decoded_token['type'] == 'refresh'
    raise TokenExpiredError, 'Token expirado' if Time.now.to_i > decoded_token['exp']
  end
end 