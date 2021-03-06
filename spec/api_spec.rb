require 'stringio'
require_relative '../lib/es_readmodel/api'

describe EsReadModel::Api do
  subject { EsReadModel::Api.new(routes) }
  let(:env) { {
    'rack.input' => StringIO.new,
    'PATH_INFO' => '/users',
    'readmodel.available' => true
  } }
  let(:response) { subject.call(env) }

  context 'when the path does not match any route' do
    let(:routes) { {
      '/unused' => Proc.new {|state, params, env| raise ArgumentError, "boom!" }
    } }

    it 'returns a 404 error' do
      expect(response[0]).to eq(404)
    end

    it 'reports that a route did not match' do
      expect(response[2][0]).to include('route')
    end
  end

  context 'when the route handler throws an API error' do
    let(:routes) { {
      '/users' => Proc.new {|state, params, env| raise EsReadModel::ApiError, "boom!" }
    } }

    it 'returns a 400 error' do
      expect(response[0]).to eq(400)
    end

    it 'includes the error message' do
      expect(response[2][0]).to include('boom!')
    end
  end

  context 'when the route handler throws an exception' do
    let(:routes) { {
      '/users' => Proc.new {|state, params, env| raise ArgumentError, "boom!" }
    } }

    it 'returns a 500 error' do
      expect(response[0]).to eq(500)
    end

    it 'mentions the exception class' do
      expect(response[2][0]).to include('ArgumentError')
    end
  end

  context 'when the route handler returns nil' do
    let(:routes) { {
      '/users' => Proc.new {|state, params, env| nil }
    } }

    it 'returns a 404 error' do
      expect(response[0]).to eq(404)
    end

    it 'reports that the read model did not find what was requested' do
      expect(response[2][0]).to include('read model')
    end
  end

  context 'when the handler adds links' do
    let(:routes) { {
      '/users' => Proc.new {|state, params, env| {xyz: :zy, _links: {a: 'b'} } }
    } }

    example 'the self link is merged with the existing links' do
      links = JSON.parse(response[2][0], symbolize_names: true)[:_links]
      expect(links.keys.length).to eq(2)
      expect(links).to have_key(:self)
      expect(links[:a]).to eq('b')
    end

  end

end

