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
  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'colsole', '~> 0.3'
  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'screencap', '~> 0.1'
  
  # Normally, we do not need to specify phantomjs as a dependency
  # since screencap is bringing it. However, screencap does not seem
  # to work with version 2.x, so we limit it here.
  # See: https://github.com/maxwell/screencap/issues/31
  s.add_runtime_dependency 'phantomjs', '~> 1.9.8', "<2.0"

  s.add_development_dependency 'runfile', '~> 0.5'
  s.add_development_dependency 'sinatra', '~> 1.4'
  s.add_development_dependency 'sinatra-contrib', '~> 1.4'
  s.add_development_dependency 'runfile-tasks', '~> 0.4'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'simplecov', '~> 0.14'
  s.add_development_dependency 'pry', '~> 0.10'

end
