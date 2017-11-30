require 'faraday'
require 'faraday_middleware'
require 'json'
require 'base64'

module EsReadModel

  class Connection

    def initialize(endpoint, username=nil, password=nil)
      @endpoint = endpoint
      @headers = {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }
      if username && password
        token = Base64.encode64("#{username}:#{password}")[0..-2]
        @headers.merge!({ 'Authorization' => "Basic #{token}" })
      end
    end

    def get(uri, etag)
      connection = Faraday.new(url: @endpoint) do |faraday|
        faraday.options[:timeout] = 2
        faraday.response :json, content_type: 'application/json'
        faraday.response :mashify
        faraday.adapter Faraday.default_adapter
      end
      response = connection.get(uri) do |req|
        req.headers = @headers
        req.headers.merge({ 'If-None-Match' => etag }) if etag
        req.body = {}.to_json
        req.params['embed'] = 'body'
      end
      response
    end

    def to_s
      @endpoint
    end

  end

end

