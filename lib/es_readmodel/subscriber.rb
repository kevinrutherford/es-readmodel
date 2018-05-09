require_relative './connection'
require_relative './stream'

module EsReadModel

  class Subscriber

    attr_reader :status, :state

    def initialize(options)
      @listener = options[:listener]
      @initial_state = options[:initial]
      url = options[:es_url]
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
    end

    def subscribe
      loop do
        begin
          @status[:available] = false
          @status[:eventStore][:connected] = false
          @state = @initial_state
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

    private

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

  end

end

