$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'mutility/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'mutility'
  s.version       = Mutility::VERSION
  s.authors       = ['Lucas Winningham']
  s.email         = ['lucas.winningham@gmail.com']
  s.homepage      = ''
  s.summary       = 'Summary of Mutility.'
  s.description   = 'Description of Mutility.'
  s.license       = 'MIT'

  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.test_files    = Dir['spec/**/*']

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.add_dependency 'rails', '~> 5.1.6', '>= 5.1.6.1'

  s.add_development_dependency 'pg', '~> 0.18.4'
  s.add_development_dependency 'rspec-rails', '~> 3.8.2'
end
