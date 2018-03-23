require 'rack'
require 'json'
require 'mustermann'

module EsReadModel

  class ApiError < StandardError
  end

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
      params = @request.params.merge(args)
      begin
        payload = @request.body.read
        body = payload.empty? ? {} : JSON.parse(payload, symbolize_names: true)
        params = params.merge(body)
        result = handler.call(@request.env['readmodel.state'], params, env)
        return result ? json_response(200, result) : json_response(404, {error: 'not found in read model'})
      rescue ApiError => ex
        return json_response(400, {
          error: ex.message
        })
      rescue Exception => ex
        return json_response(500, {
          error: "#{ex.class.name}: #{ex.message}",
          backtrace: ex.backtrace,
          params: params
        })
      end
    end

    def json_response(status_code, body)
      if body.has_key?(:_links)
        body[:_links][:self] = @request.fullpath
      else
        body = body.merge({
          _links: { self: @request.fullpath }
        })
      end
      [
        status_code,
        {
          'Content-Type' => 'application/json'
        },
        [body.to_json]
      ]
    end

  end

end

