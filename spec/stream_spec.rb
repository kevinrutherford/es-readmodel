require_relative '../lib/es_readmodel/stream'

RSpec.describe EsReadModel::Stream do
  let(:connection) { double('Connection') }
#   let(:base_etag) { random_word }
  let(:stream_name) { random_word }
  #subject { ReadModel::Stream.new(stream_name, connection) }

  describe '#initialize' do

    context 'when EventStore is not available' do
      example 'the stream retries at doubling intervals'
    end

    context 'when EventStore is available' do
      context 'but fetching the first page of events fails' do
        example 'the stream retries at doubling intervals'
      end

      context 'and there are no waiting events' do
        example 'the stream sits on the current page'
      end

      context 'and there are 2 pages of events waiting' do
        example 'the stream fetches the head'
      end

    end

  end

  describe '#each_event' do
    context 'when there are 2 pages of events waiting' do
      context 'and EventStore behaves itself' do
        example 'all events are yielded'
        example 'both pages are fetched'
      end

      context 'but EventStore disappears after the first page' do
        example 'the stream throws an exception'
      end

    end
  end

#   context 'when the stream has more than one page of events' do
#     let(:last_uri) { "#{stream_name}/last" }
#     let(:head_page) {
#       FakeResponse.new({'etag' => base_etag}, {
#         'links' => [{'uri' => last_uri, 'relation' => 'last'}],
#         'entries' => []
#       })
#     }
#     let(:previous_uri) { "#{random_word}/prev" }
#     let(:last_page) {
#       FakeResponse.new({'etag' => base_etag}, {
#         'links' => [{'uri' => previous_uri, 'relation' => 'previous'}],
#         'entries' => [{'type' => 'boo', 'data' => '{"id": 3}'},{'type' => 'boo', 'data' => '{"id": 4}'}]
#       })
#     }
#     let(:first_etag) { random_word }
#     let(:first_page) {
#       FakeResponse.new({'etag' => first_etag}, {
#         'links' => [{'uri' => last_uri, 'relation' => 'last'}],
#         'entries' => []
#       })
#     }

#     before do
#       expect(connection).to receive(:get).with("/streams/#{stream_name}", nil).and_return(head_page)
#       expect(connection).to receive(:get).with(last_uri, base_etag).and_return(last_page)
#       expect(connection).to receive(:get).with(previous_uri, base_etag).and_return(first_page)
#     end

#     it 'yields the entries in all pages, starting with the last' do
#       yielded = []
#       subject.each {|evt| yielded << evt.data[:id] }
#       expect(yielded).to eq([4, 3])
#     end

#     it 'returns the correct ref' do
#       ref = subject.each {|evt| }
#       expect(ref).to eq(EsHttpClient::Ref.new(previous_uri, first_etag))
#     end
#   end

#   context 'when the head of stream is also the last page' do
#     let(:previous_uri) { "#{stream_name}/prev" }
#     let(:previous_etag) { random_word }
#     let(:head_page) {
#       FakeResponse.new({'etag' => base_etag}, {
#         'links' => [{'uri' => previous_uri, 'relation' => 'previous'}],
#         'entries' => [{'type' => 'boo', 'data' => '{"id": 1}'},{'type' => 'boo', 'data' => '{"id": 2}'}]
#       })
#     }
#     let(:previous_page) {
#       FakeResponse.new({'etag' => previous_etag}, {
#         'links' => [{'uri' => random_word, 'relation' => 'last'}],
#         'entries' => []
#       })
#     }

#     before do
#       expect(connection).to receive(:get).with("/streams/#{stream_name}", nil).and_return(head_page)
#       expect(connection).to receive(:get).with(previous_uri, base_etag).and_return(previous_page)
#     end

#     it 'yields the entries from the head page in reverse order' do
#       yielded = []
#       subject.each {|evt| yielded << evt.data[:id] }
#       expect(yielded).to eq([2, 1])
#     end

#     it 'returns the correct ref' do
#       ref = subject.each {|evt| }
#       expect(ref).to eq(EsHttpClient::Ref.new(previous_uri, previous_etag))
#     end
#   end

end

