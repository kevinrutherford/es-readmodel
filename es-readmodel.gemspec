# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'es-readmodel'
  spec.version       = '0.0.8'
  spec.licenses      = ['MIT']
  spec.authors       = ['Kevin Rutherford']
  spec.email         = ['kevin@rutherford-software.com']

  spec.summary       = %q{An opinionated read model framework for use with EventStore}
  spec.description   = %q{An opinionated read model framework for use with EventStore}
  spec.homepage      = "https://github.com/kevinrutherford/es-readmodel"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack', '~> 2.0'
  spec.add_runtime_dependency 'faraday', '~> 0.13'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.12'
  spec.add_runtime_dependency 'hashie', '~> 3.5'
  spec.add_runtime_dependency 'json', '~> 2.1'
  spec.add_runtime_dependency 'mustermann', '~> 1.0'

  spec.add_development_dependency 'rspec', '~> 3.7'

end

