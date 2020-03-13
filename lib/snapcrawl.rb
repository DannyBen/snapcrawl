require 'snapcrawl/version'
require 'snapcrawl/exceptions'
require 'snapcrawl/refinements'
require 'snapcrawl/dependencies'
require 'snapcrawl/logging'
require 'snapcrawl/screenshot'
require 'snapcrawl/page'
require 'snapcrawl/crawler'
require 'snapcrawl/cli'

if ENV['BYEBUG']
  require 'byebug'
  require 'lp'
end
