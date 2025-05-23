# router.rb
require 'sinatra/base'
require 'sinatra/json'
require_relative './app'

class Router < Sinatra::Base
  def self.instance
    @instance ||= new
  end

  def initialize
    super
    @app = App.new
  end

  # Configuración
  set :show_exceptions, false
  set :raise_errors, true

  # Rutas
  post '/auth' do
    handle_request do |req, res|
      @app.auth(req, res)
    end
  end

  post '/register' do
    handle_request do |req, res|
      @app.register(req, res)
    end
  end

  post '/refresh' do
    handle_request do |req, res|
      @app.refresh(req, res)
    end
  end

  post '/products' do
    handle_request do |req, res|
      @app.create_product(req, res)
    end
  end

  get '/products' do
    handle_request do |req, res|
      @app.list_products(res)
    end
  end

  get '/openapi.yaml' do
    res = Rack::Response.new
      @app.serve_openapi(res)
    res.finish
  end

  get '/' do
    puts "[DEBUG] Entrando a ruta /"
    file_path = File.join(__dir__, 'AUTHORS')
    puts "[DEBUG] Buscando archivo en: #{file_path}"
    if File.exist?(file_path)
      content_type 'text/plain'
      cache_control :public, max_age: 86400  # 24 horas
      File.read(file_path)
    else
      halt 404, 'AUTHORS file not found'
    end
  end

# catch-all 404
  not_found do
    content_type :json
    status 404
    { error: 'Not Found' }.to_json
  end

  private

  def handle_request
    puts "\n=== INICIO HANDLE REQUEST ==="
    puts "REQUEST PATH: #{request.path}"
    puts "REQUEST METHOD: #{request.request_method}"
    puts "REQUEST CONTENT_TYPE: #{request.content_type}"
    puts "REQUEST BODY: #{request.body.read}"
    request.body.rewind

    req = request
    res = Rack::Response.new

    begin
      yield(req, res)
      puts "RESPONSE STATUS: #{res.status}"
      puts "RESPONSE BODY: #{res.body}"
      puts "=== FIN HANDLE REQUEST ===\n"
      res.finish
    rescue JSON::ParserError => e
      puts "ERROR JSON: #{e.message}"
      content_type :json
      status 400
      { error: 'JSON inválido' }.to_json
    rescue StandardError => e
      puts "ERROR EN HANDLE REQUEST: #{e.message}"
      puts "BACKTRACE: #{e.backtrace.join("\n")}"
      content_type :json
      status 500
      { error: 'Error interno del servidor', details: e.message }.to_json
    end
  end
end

# Export the router instance
#ROUTER = Router.instance
