# app.rb
require 'json'
require 'rack'
require_relative './product_store'
require_relative './auth'

class App
  def initialize
    @store = ProductStore.new
    @auth = Auth.new
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    begin
      case [req.request_method, req.path]
      when ['POST', '/auth']
        @auth.handle_auth(req, res)
      when ['POST', '/register']
        @auth.register(req, res)
      when ['POST', '/refresh']
        @auth.refresh_token(req, res)
      when ['POST', '/products']
        handle_create_product(req, res)
      when ['GET', '/products']
        handle_list_products(res)
      when ['GET', '/openapi.yaml']
        res['Content-Type'] = 'application/yaml'
        res['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
        res.write(File.read('openapi.yaml'))
      else
        res.status = 404
        res.write({ error: 'Not Found' }.to_json)
      end
    rescue JSON::ParserError
      res.status = 400
      res.write({ error: 'JSON inválido' }.to_json)
    rescue => e
      res.status = 500
      res.write({ error: 'Error interno del servidor', details: e.message }.to_json)
    end

    res['Content-Type'] = 'application/json'
    res.finish
  end

  def handle_create_product(req, res)
    body = JSON.parse(req.body.read)
    id = @store.add_async(body['name'])
    res.status = 202
    res.write({ message: 'Product creation scheduled', id: id }.to_json)
  end

  def handle_list_products(res)
    res.write(@store.all.to_json)
  end
end
