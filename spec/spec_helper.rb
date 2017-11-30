$LOAD_PATH << File.expand_path('.')

Dir['spec/support/**/*.rb'].each {|f| require_relative "../#{f}" }

RSpec::Matchers.define :an_event_like do |expected|
  match { |actual|
    actual.type == expected.type &&
    actual.data.reject {|k,v| k == :occurredAt } == expected.data.reject {|k,v| k == :occurredAt}
  }
end

RSpec::Matchers.define :be_the_same_event_as do |expected|
  match { |actual|
    actual.id == event.id &&
    actual.type == event.type &&
    actual.data == event.data &&
    actual.occurred_at == event.occurred_at
  }
end

RSpec.configure do |config|

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed

  config.include EventHelpers
  config.include RandomHelpers

  config.alias_it_should_behave_like_to :it_is, 'it is'

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end

class FakeResponse < Struct.new(:headers, :body); end

