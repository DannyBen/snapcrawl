# SnapCrawl - crawl a website and take screenshots

`snapcrawl` is a command line utility for crawling a website and saving
screenshots. It is using [Runfile](https://github.com/DannyBen/runfile).

## Features

- Crawl a website to any given depth
- Save full screenshots of all crawled pages
- Skips capturing if the screenshot was already saved recently
- Uses local caching to avoid expensive crawl operations if not needed

## Install Gem Dependencies

Option 1, with bundler:

	$ bundle

Option 2, manually:

	$ gem install runfile
	$ gem install nokogiri
	$ gem install screencap

## Usage

	$ run --help


## TODO

[ ] Add caching options to command line
[ ] Add ignore regexes to command line or config
[ ] Add exception handling for when snapping fails




