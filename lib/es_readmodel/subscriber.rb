require 'rack'
require 'json'
require_relative './connection'
require_relative './stream'

module EsReadModel

  class Subscriber

    attr_reader :status

    def initialize(app, options)
      @app = app
      @listener = options[:listener]
      url = "http://#{options[:es_host]}:#{options[:es_port]}"
      @status = {
        available: false,
        startedAt: Time.now,
        eventsReceived: 0,
        eventStore: {
          url: url,
          connected: true,
          disconnects: 0
        }
      }
      @connection = Connection.new(url, options[:es_username], options[:es_password])
      @reducer = options[:reducer]
      Thread.new { subscribe }
    end

    def call(env)
      @request = Rack::Request.new(env)
      if env['PATH_INFO'] == '/status'
        status, headers, body = json_response(200, @status)
      else
        env['readmodel.state'] = @state
        env['readmodel.available'] = @status[:available]
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

    def subscribe
      loop do
        begin
          @status[:available] = false
          @status[:eventStore][:connected] = false
          @state = nil
          @stream = Stream.open("$all", @connection, @listener)
          @status[:eventStore][:connected] = true
          @status[:eventStore][:lastConnect] = Time.now
          subscribe_to_all_events
        rescue Exception => ex
          @listener.call({
            level: 'error',
            tag:   'connection.error',
            msg:   "#{ex.class}: #{ex.message}"
          })
          @status[:eventStore][:disconnects] = @status[:eventStore][:disconnects] + 1
          @status[:eventStore][:lastDisconnect] = Time.now
        end
      end
    end

    def subscribe_to_all_events
      loop do
        @status[:available] = true
        @stream.wait_for_new_events
        @status[:available] = false
        num_events_processed = 0
        @stream.each_event do |evt|
          begin
            @state = @reducer.call(@state, evt)
          rescue Exception => ex
            @listener.call({
              level: 'error',
              tag:   'reducer.error',
              msg:   "Error in reducer: #{ex.class}: #{ex.message}. Read model state not updated."
            })
          end
          @status[:eventsReceived] = @status[:eventsReceived] + 1
          num_events_processed += 1
        end
        @listener.call({
          level: 'info',
          tag:   'subscription.caughtUp',
          msg:   "Subscription to $all caught up",
          eventsProcessed: num_events_processed
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

