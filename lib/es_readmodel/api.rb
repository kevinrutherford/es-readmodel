require 'rack'
require 'json'
require 'mustermann'

module EsReadModel

  class Api

    def initialize(routes)
      @routes = routes
    end

    def call(env)
      @request = Rack::Request.new(env)
      path = @request.path_info
      @routes.each do |route, handler|
        args = Mustermann.new(route).params(path)
        return invoke_handler(handler, args, env) if args
      end
      return json_response(404, {error: 'path did not match any route'})
    end

    private

    def invoke_handler(handler, args, env)
      return json_response(503, {status: env['readmodel.status']}) unless env['readmodel.available'] == true
      begin
        result = handler.call(@request.env['readmodel.state'], @request.params.merge(args))
        return result ? json_response(200, result) : json_response(404, {error: 'not found in read model'})
      rescue Exception => ex
        return json_response(500, {
          error: "#{ex.class.name}: #{ex.message}",
          backtrace: ex.backtrace
        })
      end
    end

    def json_response(status_code, body)
      result = body.merge({
        _links: { self: @request.fullpath }
      })
      [
        status_code,
        {
          'Content-Type' => 'application/json'
        },
        [result.to_json]
      ]
    end

  end

end

