require 'snapcrawl/version'
require 'snapcrawl/exceptions'
require 'snapcrawl/refinements/pair_split'
require 'snapcrawl/refinements/string_refinements'
require 'snapcrawl/log_helpers'
require 'snapcrawl/pretty_logger'
require 'snapcrawl/dependencies'
require 'snapcrawl/config'
require 'snapcrawl/screenshot'
require 'snapcrawl/page'
require 'snapcrawl/crawler'
require 'snapcrawl/cli'

if ENV['BYEBUG']
  require 'byebug'
  require 'lp'
end

Snapcrawl::Config.load
$logger = Snapcrawl::PrettyLogger.new
