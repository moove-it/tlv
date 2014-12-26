Gem::Specification.new do |s|
  s.name          = 'tlv'
  s.version       = '0.0.1'
  s.platform      = Gem::Platform::RUBY

  s.authors       = ['Adrian Gomez', 'Tim Becker']
  s.email         = "adrian.gomez@moove-it.com"
  s.homepage      = "https://github.com/a2800276/hexy"
  s.summary       = 'Parse and generate tlv.'

  s.files         = Dir.glob('{lib}/**/*')
  s.description   = 'Utilities to parse and generate tlv with ease.'

  s.add_dependency('rspec', '~> 3')
  s.add_development_dependency('simplecov', '~> 0', '>= 0.9.1')
  s.add_development_dependency('simplecov-rcov', '~> 0', '>= 0.2.3')
  s.add_development_dependency('simplecov-rcov-text', '~> 0', '>= 0.0.3')
  s.add_development_dependency('ci_reporter_rspec', '~> 1')
end