lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
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
  s.add_runtime_dependency 'net-ssh', '~> 3.0'
  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'screencap', '~> 0.1'

  s.add_development_dependency 'runfile', '~> 0.5'
  s.add_development_dependency 'run-gem-dev', '~> 0.2'
  # s.add_development_dependency 'minitest', '~> 5.8'
  # s.add_development_dependency 'minitest-reporters', '~> 1.1'
  # s.add_development_dependency 'rake', '~> 10.4'
  # s.add_development_dependency 'simplecov', '~> 0.10'

end
