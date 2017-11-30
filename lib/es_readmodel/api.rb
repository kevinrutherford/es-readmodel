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
        pattern = Mustermann.new(route)
        args = pattern.params(path)
        if args
          return json_response(503, {status: env['readmodel.status']}) unless env['readmodel.available'] == true
          result = handler.call(@request.env['readmodel.state'], @request.params.merge(args))
          return result ? json_response(200, result) : json_response(404, {error: 'not found'})
        end
      end
      return json_response(404, {error: 'not found'})
    end

    private

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

