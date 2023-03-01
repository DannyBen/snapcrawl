lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snapcrawl/version'

Gem::Specification.new do |s|
  s.name        = 'snapcrawl'
  s.version     = Snapcrawl::VERSION
  s.summary     = 'Crawl a website and take screenshots (CLI + Library)'
  s.description = 'Snapcrawl is a command line utility for crawling a website and saving screenshots.'
  s.authors     = ['Danny Ben Shitrit']
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*']
  s.executables = ['snapcrawl']
  s.homepage    = 'https://github.com/DannyBen/snapcrawl'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'addressable', '~> 2.7'
  s.add_runtime_dependency 'colsole', '>= 0.8.1', '< 2'
  s.add_runtime_dependency 'docopt', '~> 0.6'
  s.add_runtime_dependency 'httparty', '~> 0.21'
  s.add_runtime_dependency 'lightly', '~> 0.3'
  s.add_runtime_dependency 'nokogiri', '~> 1.10'
  s.add_runtime_dependency 'sting', '~> 0.4'
  s.add_runtime_dependency 'webshot', '~> 0.1'
  s.metadata['rubygems_mfa_required'] = 'true'
end
