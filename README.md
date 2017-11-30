# EsReadModel

An opinionated read model framework for EventStore.

Your reducer can be anything that responds to #call.
It will receive two arguments -- the current state and the event.
The current state will be nil if no events have bee processed yet.
The reducer function must return the new state.

## Example usage

```[ruby]
require 'rack/cors'
require 'es_readmodel'
require_relative './active_users'
require_relative './list_users'
require_relative './get_user_details'

ENV['RACK_ENV'] = 'none'
ENV['readmodel.name'] = 'users'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :any, max_age: 0
  end
end

use EsReadModel::Subscriber,
  es_host:     ENV['ES_HOST'],
  es_port:     ENV['ES_PORT'],
  es_username: ENV['ES_USERNAME'],
  es_password: ENV['ES_PASSWORD'],
  reducer:     ActiveUsers.new,
  listener:    EsReadModel::Logger.new

run EsReadModel::Api.new(
  '/users'          => ListUsers.new,
  '/users/:user_id' => GetUserDetails.new
)

```

