require_relative './page'

module EsReadModel

  class Stream

    def Stream.open(name, connection, listener)
      Stream.new("/streams/#{name}", connection, listener)
    end

    def initialize(head_uri, connection, listener)
      @connection = connection
      @listener = listener
      @current_etag = nil
      fetch_first_page(head_uri)
    end

    def wait_for_new_events
      while @current_page.empty?
        sleep 1
        fetch(@current_uri)
      end
    end

    def each_event(&blk)
      while !@current_page.empty?
        @current_page.each_event(&blk)
        fetch(@current_page.newer_events_uri) if @current_page.newer_events_uri
      end
    end

    private

    def fetch_first_page(uri)
      back_off = 1
      @listener.call({
        level: 'info',
        tag:   'fetchFirstPage.connecting',
        msg:   "Connecting to #{uri} on #{@connection}"
      })
      loop do
        begin
          fetch(uri)
          last = @current_page.first_event_uri
          fetch(last) if last
          @listener.call({
            level: 'info',
            tag:   'fetchFirstPage.connected',
            msg:   "Connected to #{uri} on #{@connection}",
            eventsWaiting: !@current_page.empty?
          })
          return
        rescue Exception => ex
          @listener.call({
            level: 'error',
            tag:   'fetchFirstPage.error',
            msg:   "#{ex.class}: #{ex.message}. Retry in #{back_off}s."
          })
          sleep back_off
          back_off *= 2
        end
      end
    end

    def fetch(uri)
      response = @connection.get(uri, @current_etag)
      @current_page = Page.new(response.body)
      @current_uri = uri
      @current_etag = response.headers['etag']
    end

  end

end

