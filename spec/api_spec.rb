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
      '/unused' => Proc.new {|state, params| raise ArgumentError, "boom!" }
    } }

    it 'returns a 404 error' do
      expect(response[0]).to eq(404)
    end

    it 'reports that a route did not match' do
      expect(response[2][0]).to include('route')
    end
  end

  context 'when the route handler throws an exception' do
    let(:routes) { {
      '/users' => Proc.new {|state, params| raise ArgumentError, "boom!" }
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
      '/users' => Proc.new {|state, params| nil }
    } }

    it 'returns a 404 error' do
      expect(response[0]).to eq(404)
    end

    it 'reports that the read model did not find what was requested' do
      expect(response[2][0]).to include('read model')
    end
  end

end

