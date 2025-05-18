# middleware/gzip.rb
require 'zlib'
require 'stringio'

class GzipMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    # Solo si el cliente acepta gzip
    if env['HTTP_ACCEPT_ENCODING'].to_s.include?('gzip')
      compressed = gzip(body)

      headers['Content-Encoding'] = 'gzip'
      headers['Content-Length'] = compressed.bytesize.to_s

      [status, headers, [compressed]]
    else
      [status, headers, body]
    end
  end

  private

  def gzip(body)
    output = StringIO.new
    gz = Zlib::GzipWriter.new(output)
    body.each { |part| gz.write(part) }
    gz.close
    output.string
  end
end
