lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
require 'snapcrawl/version'

Gem::Specification.new do |s|
  s.name        = 'snapcrawl'
  s.version     = Snapcrawl::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Crawl a website and take screenshots (CLI + Library)"
  s.description = "Snapcrawl is a command line utility for crawling a website and saving screenshots."
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.rb', 'lib/snapcrawl/templates/*']
  s.executables = ["snapcrawl"]
  s.homepage    = 'https://github.com/DannyBen/snapcrawl'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.3'

  s.add_runtime_dependency 'colsole', '~> 0.5', '>= 0.5.4'
  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'webshot', '~> 0.1'
  s.add_runtime_dependency 'httparty', '~> 0.17'
  s.add_runtime_dependency 'addressable', '~> 2.7'
end
