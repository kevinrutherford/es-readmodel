require_relative './event'

module EsReadModel

  class Page

    def initialize(body)
      @body = body
    end

    def first_event_uri
      find_link('last')
    end

    def newer_events_uri
      find_link('previous')
    end

    def empty?
      @body['entries'].nil? || @body['entries'].empty?
    end

    def each_event(&block)
      @body['entries']
        .reverse!
        .map {|e| Event.load_from(e)}
        .compact
        .select {|e| e.type !~ /^\$/ }
        .each {|e| yield e }
    end

    private

    def find_link(rel)
      link = @body['links'].detect { |l| l['relation'] == rel }
      link.nil? ? nil : link['uri']
    end

  end

end

