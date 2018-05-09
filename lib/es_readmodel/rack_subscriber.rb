require 'rack'
require 'json'
require_relative './subscriber'

module EsReadModel

  class RackSubscriber

    attr_reader :status

    def initialize(app, options)
      @app = app
      @listener = options[:listener]
      @subscriber = Subscriber.new(options)
      Thread.new { @subscriber.subscribe }
    end

    def call(env)
      @request = Rack::Request.new(env)
      if env['PATH_INFO'] == '/status'
        status, headers, body = json_response(200, @subscriber.status)
      else
        env['readmodel.state'] = @subscriber.state
        env['readmodel.available'] = @subscriber.status[:available]
        env['readmodel.status'] = 'OK'
        status, headers, body = @app.call(env)
      end
      @listener.call({
        level:  'info',
        tag:    'http.request',
        msg:    "#{env['REQUEST_METHOD']} #{@request.fullpath}",
        status: status
      })
      [status, headers, body]
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

