# app.rb
require 'json'
require_relative './product_store'
require_relative './auth'

class App
  def initialize
    @auth = Auth.new
  end

  def auth(req, res)
    @auth.handle_auth(req, res)
  end

  def register(req, res)
    @auth.register(req, res)
  end

  def refresh(req, res)
    @auth.refresh_token(req, res)
  end

  def create_product(req, res)
    body = JSON.parse(req.body.read)
    id = ProductStore.add_async(body['name'])
    res.status = 202
    res.write({ message: 'Product creation scheduled', id: id }.to_json)
  end

  def list_products(res)
    res.write(ProductStore.all.to_json)
  end

  def serve_openapi(res)
    res['Content-Type'] = 'application/yaml'
    res['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    res.write(File.read('openapi.yaml'))
  end
end
