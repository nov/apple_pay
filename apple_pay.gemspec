Gem::Specification.new do |spec|
  spec.name = 'apple_pay'
  spec.version = File.read('VERSION')
  spec.authors = ['Nov Matake']
  spec.email = ['nov@matake.jp']

  spec.summary = %q{Apple Pay Merchant Backend}
  spec.description = %q{Apple Pay Merchant Backend}
  spec.homepage = 'https://github.com/nov/apple_pay.git'
  spec.license = 'MIT'
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'httpclient'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
end
